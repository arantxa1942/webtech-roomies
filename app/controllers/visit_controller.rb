class VisitsController < ApplicationController
  before_action :set_visit, only: %i[update destroy]
  before_action :authorize_host!, only: %i[create update destroy]


  def create
    @application = Application.find(params[:application_id])

    unless @application.shortlisted?
      redirect_to application_path(@application),
                  alert: "You can only propose a visit for a shortlisted application."
      return
    end

    @visit = @application.build_visit(
      scheduled_at: visit_params[:scheduled_at],
      notes: visit_params[:notes],
      status: :proposed
    )

    if @visit.save
      redirect_to application_path(@application), notice: "Visit proposed."
    else
      redirect_to application_path(@application),
                  alert: @visit.errors.full_messages.to_sentence
    end
  end

  
  def update
    if invalid_status_transition?
      redirect_to application_path(@visit.application),
                  alert: "That visit status change is not allowed."
      return
    end

    if @visit.update(visit_params)
      redirect_to application_path(@visit.application), notice: "Visit updated."
    else
      redirect_to application_path(@visit.application),
                  alert: @visit.errors.full_messages.to_sentence
    end
  end

  
  def destroy
    application = @visit.application

    if @visit.destroy
      redirect_to application_path(application), notice: "Visit deleted."
    else
      redirect_to application_path(application),
                  alert: @visit.errors.full_messages.to_sentence
    end
  end

  private

  def set_visit
    @visit = Visit.find(params[:id])
  end

  
  def authorize_host!
    visit = @visit

    if visit.nil? && params[:application_id].present?
      application = Application.find(params[:application_id])
      visit = application.visit
      property = application.listing.property
    elsif visit.present?
      property = visit.application.listing.property
    end

    unless property&.owner_id == current_user&.id
      redirect_to root_path, alert: "You are not allowed to manage this visit."
    end
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at, :notes, :status)
  end

  def invalid_status_transition?
    return false unless visit_params[:status].present?

    allowed_transitions = {
      "proposed" => %w[confirmed cancelled],
      "confirmed" => %w[cancelled completed],
      "cancelled" => [],
      "completed" => []
    }

    allowed_transitions.fetch(@visit.status, []).exclude?(visit_params[:status])
  end
end