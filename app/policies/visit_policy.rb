class VisitPolicy < ApplicationPolicy
  def create?
    participant?
  end

  def update?
    participant?
  end

  def confirm?
    participant?
  end

  def cancel?
    participant?
  end

  def complete?
    host?
  end

  private

  def application
    record.application
  end

  def host?
    signed_in? && application&.listing&.property&.owner_id == user.id
  end

  def applicant?
    signed_in? && application&.applicant_id == user.id
  end

  def participant?
    host? || applicant?
  end
end