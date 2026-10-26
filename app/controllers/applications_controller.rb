class ApplicationsController < ApplicationController
  before_action :set_application, only: %i[show shortlist reject accept withdraw]
  before_action :authorize_application_view!, only: :show
  before_action :authorize_host!, only: %i[shortlist reject accept]
  before_action :authorize_applicant!, only: :withdraw

  def index
    @applications = Application
      .joins(listing: :property)
      .where(properties: { owner_id: current_user.id })
      .includes(:applicant, listing: :property)
      .order(created_at: :desc)

    @pending_count = @applications.pending.count
  end

  def show
    @visit = @application.visit
  end

  def create
    @listing = Listing.find(params[:listing_id])
    @application = @listing.applications.build(application_params)
    @application.applicant = current_user

    if @application.save
      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing), notice: "Application submitted."
        end

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "application_block",
            partial: "applications/application_block",
            locals: { listing: @listing, application: @application }
          )
        end
      end
    else
      respond_to do |format|
        format.html do
          redirect_to listing_path(@listing),
                      alert: @application.errors.full_messages.to_sentence
        end

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "application_block",
            partial: "applications/application_block",
            locals: { listing: @listing, application: @application }
          ), status: :unprocessable_entity
        end
      end
    end
  end

  def shortlist
    update_status(:shortlisted, "Application shortlisted.")
  end

  def reject
    update_status(:rejected, "Application rejected.")
  end

  def accept
    listing = @application.listing

    begin
      Application.transaction do
        @application.update!(status: :accepted)

        listing.applications
               .where(status: %w[pending shortlisted])
               .where.not(id: @application.id)
               .find_each do |other_application|
          other_application.update!(status: :rejected)
        end

        listing.update!(status: :reserved)
      end

      respond_to_status_change("Application accepted.")
    rescue ActiveRecord::RecordInvalid => error
      redirect_to applications_path,
                  alert: error.record.errors.full_messages.to_sentence
    end
  end

  def withdraw
    unless @application.pending? || @application.shortlisted?
      redirect_to application_path(@application),
                  alert: "Only pending or shortlisted applications can be withdrawn."
      return
    end

    if @application.update(status: :withdrawn)
      redirect_to listing_path(@application.listing),
                  notice: "Application withdrawn."
    else
      redirect_to application_path(@application),
                  alert: @application.errors.full_messages.to_sentence
    end
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
    is_applicant = @application.applicant_id == current_user&.id
    is_host = @application.listing.property.owner_id == current_user&.id
    return if is_applicant || is_host

    redirect_to root_path, alert: "You are not allowed to view this application."
  end

  def update_status(status, success_message)
    if @application.update(status: status)
      respond_to_status_change(success_message)
    else
      redirect_to applications_path,
                  alert: @application.errors.full_messages.to_sentence
    end
  end

  def respond_to_status_change(success_message)
    respond_to do |format|
      format.html do
        redirect_to applications_path, notice: success_message
      end

      format.turbo_stream do
        @applications = Application
          .joins(listing: :property)
          .where(properties: { owner_id: current_user.id })
          .includes(:applicant, listing: :property)
          .order(created_at: :desc)

        @pending_count = @applications.pending.count

        changed_applications =
          if @application.accepted?
            @application.listing.applications.includes(:applicant, listing: :property)
          else
            [@application]
          end

        streams = changed_applications.map do |application|
          turbo_stream.replace(
            dom_id(application),
            partial: "applications/application_row",
            locals: { application: application }
          )
        end

        streams << turbo_stream.replace(
          "pending_count",
          partial: "applications/pending_count",
          locals: { pending_count: @pending_count }
        )

        render turbo_stream: streams
      end
    end
  end
end