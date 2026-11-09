class VisitPolicy < ApplicationPolicy
  def create?
    !moderator? && participant?
  end

  def update?
    !moderator? && participant?
  end

  def confirm?
    !moderator? && participant?
  end

  def cancel?
    !moderator? && participant?
  end

  def complete?
    !moderator? && host?
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