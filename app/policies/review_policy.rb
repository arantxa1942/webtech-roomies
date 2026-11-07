class ReviewPolicy < ApplicationPolicy
  def create?
    signed_in? && !moderator? && own_completed_visit?
  end

  def update?
    author?
  end

  def destroy?
    author? || moderator?
  end

  private

  def author?
    signed_in? && record.reviewer_id == user.id
  end

  def own_completed_visit?
    visit = record.visit
    visit.present? && visit.completed? && visit.application.applicant_id == user.id
  end
end