class ApplicationsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_application, only: %i[show shortlist reject accept withdraw]
 

  def index
    authorize Application
    load_inbox
  end


  def show
    @visit = @application.visit
  end

  def create
    @listing = Listing.find(params[:listing_id])
    @application = @listing.applications.build(application_params)
    @application.applicant = current_user
    authorize @application
    if @application.save
      if turbo_frame_request?
        # Turbo Frame: only the application block is replaced, in place.
        render_application_block(@application)
      else
        redirect_to @listing, notice: "Application submitted successfully."
      end
    elsif turbo_frame_request?
      render_application_block(@application, status: :unprocessable_entity)
    else
      redirect_to @listing, alert: "Error: #{@application.errors.full_messages.to_sentence}"
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

    if turbo_frame_request?
      render_application_block(@application)
    else
      redirect_to listing_path(@application.listing), notice: "Application withdrawn."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to listing_path(@application.listing), alert: e.record.errors.full_messages.to_sentence
  end

  private
  def load_inbox
    visible = policy_scope(Application).includes(:applicant, listing: :property).order(created_at: :desc)

    @applications = visible.joins(listing: :property).where(properties: { owner_id: current_user.id })
    @pending_count = @applications.pending.count

    @my_applications = visible.where(applicant_id: current_user.id)

    @all_applications = visible if current_user.moderator?
  end
  def set_application
    @application = policy_scope(Application).includes(listing: :property).find(params[:id])
    authorize @application
  end

  def render_application_block(application, status: :ok)
    render partial: "applications/application_block",
           locals: { listing: application.listing, application: application },
           status: status
  end

  def application_params
    params.fetch(:application, {}).permit(:message, :move_in_date, :stay_length)
  end


  def respond_to_transition(action, message)
    begin
      automatically_rejected_ids = []

      if action == :accept!
        @application.listing.with_lock do
          automatically_rejected_ids =
            @application.listing.applications
                        .where(status: %w[pending shortlisted])
                        .where.not(id: @application.id)
                        .pluck(:id)

          @application.public_send(action)
        end
      else
        @application.public_send(action)
      end
    rescue ActiveRecord::RecordInvalid => e
      return respond_with_error(e.record.errors.full_messages.to_sentence)
    end

    notification_ids = [@application.id] + automatically_rejected_ids

    notification_ids.each do |application_id|
      ApplicationNotificationJob.perform_later(application_id)
    end

    respond_to do |format|
      format.html { redirect_to applications_path, notice: message }
      format.turbo_stream do
        load_inbox
        flash.now[:notice] = message

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