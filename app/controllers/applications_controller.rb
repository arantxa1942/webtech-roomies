class ApplicationsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_application, only: %i[show shortlist reject accept withdraw]
  before_action :authorize_application_view!, only: :show
  before_action :authorize_host!, only: %i[shortlist reject accept]
  before_action :authorize_applicant!, only: :withdraw

  def index
    load_inbox
  end

  def show
    @visit = @application.visit
  end

  # Turbo Frame: responde solo el bloque de aplicación.
  def create
    @listing = Listing.find(params[:listing_id])
    @application = @listing.applications.build(application_params)
    @application.applicant = current_user

    if @application.save
      redirect_to listing_path(@listing), notice: "Application submitted."
    else
      render partial: "applications/application_block",
             locals: { listing: @listing, application: @application },
             status: :unprocessable_entity
    end
  end

  def shortlist
    respond_to_transition(:shortlist!, "Application shortlisted.")
  end

  def reject
    respond_to_transition(:reject!, "Application rejected.")
  end

  def accept
    respond_to_transition(:accept!, "Application accepted. The other applications were rejected.")
  end

  def withdraw
    @application.withdraw!
    redirect_to listing_path(@application.listing), notice: "Application withdrawn."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to listing_path(@application.listing), alert: e.record.errors.full_messages.to_sentence
  end

  private

  def set_application
    @application = Application.includes(listing: :property).find(params[:id])
  end

  def application_params
    params.require(:application).permit(:message, :move_in_date, :stay_length)
  end

  def authorize_host!
    return if @application.listing.property.owner_id == current_user&.id
    redirect_to root_path, alert: "You are not allowed to manage this application."
  end

  def authorize_applicant!
    return if @application.applicant_id == current_user&.id
    redirect_to root_path, alert: "You are not allowed to withdraw this application."
  end

  def authorize_application_view!
    allowed = @application.applicant_id == current_user&.id ||
              @application.listing.property.owner_id == current_user&.id
    redirect_to root_path, alert: "You are not allowed to view this application." unless allowed
  end

  def load_inbox
    @applications = Application
      .joins(listing: :property)
      .where(properties: { owner_id: current_user.id })
      .includes(:applicant, listing: :property)
      .order(created_at: :desc)
    @pending_count = Application.joins(listing: :property)
                                .where(properties: { owner_id: current_user.id })
                                .pending.count
  end

  def respond_to_transition(action, message)
    begin
      @application.public_send(action)
    rescue ActiveRecord::RecordInvalid => e
      return respond_with_error(e.record.errors.full_messages.to_sentence)
    end

    respond_to do |format|
      format.html { redirect_to applications_path, notice: message }
      format.turbo_stream do
        load_inbox
        flash.now[:notice] = message

        # Si se aceptó, también cambian las filas que se rechazaron automáticamente.
        changed =
          if @application.accepted?
            @application.listing.applications.includes(:applicant, listing: :property)
          else
            [ @application.reload ]
          end

        streams = changed.map do |app|
          turbo_stream.replace(dom_id(app), partial: "applications/application_row", locals: { application: app })
        end
        streams << turbo_stream.replace("pending_count", partial: "applications/pending_count",
                                        locals: { pending_count: @pending_count })
        streams << turbo_stream.update("flash", partial: "shared/flash")
        render turbo_stream: streams
      end
    end
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { redirect_to applications_path, alert: message }
      format.turbo_stream do
        flash.now[:alert] = message
        render turbo_stream: turbo_stream.update("flash", partial: "shared/flash")
      end
    end
  end
end
