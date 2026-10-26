class VisitsController < ApplicationController
  before_action :set_application
  before_action :authorize_host!
  before_action :set_visit, only: %i[update destroy confirm cancel complete]

  def create
    @visit = Visit.new(visit_params)
    @visit.application = @application

    if @visit.save
      redirect_to application_path(@application), notice: "Visit proposed."
    else
      redirect_to application_path(@application), alert: @visit.errors.full_messages.to_sentence
    end
  end

  # Reprogramar: vuelve a "proposed" para que se confirme de nuevo.
  def update
    unless @visit.proposed? || @visit.confirmed?
      return redirect_to application_path(@application),
                         alert: "Only proposed or confirmed visits can be rescheduled."
    end

    if @visit.update(visit_params.merge(status: "proposed"))
      redirect_to application_path(@application), notice: "Visit rescheduled."
    else
      redirect_to application_path(@application), alert: @visit.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @visit.destroy
      redirect_to application_path(@application), notice: "Visit deleted."
    else
      redirect_to application_path(@application), alert: @visit.errors.full_messages.to_sentence
    end
  end

  def confirm
    change_status(:confirm!, "Visit confirmed.")
  end

  def cancel
    change_status(:cancel!, "Visit cancelled.")
  end

  def complete
    change_status(:complete!, "Visit marked as completed. The applicant can now review the property.")
  end

  private

  def set_application
    @application = Application.includes(listing: :property).find(params[:application_id])
  end

  def set_visit
    @visit = @application.visit || raise(ActiveRecord::RecordNotFound)
  end

  def authorize_host!
    return if @application.listing.property.owner_id == current_user&.id
    redirect_to root_path, alert: "You are not allowed to manage this visit."
  end

  def change_status(action, message)
    @visit.public_send(action)
    redirect_to application_path(@application), notice: message
  rescue ActiveRecord::RecordInvalid => e
    redirect_to application_path(@application), alert: e.record.errors.full_messages.to_sentence
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at, :notes)
  end
end
