class RoomApplicationPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

 
  def show?
    applicant? || host? || moderator?
  end

  
  def create?
    signed_in? && !host?
  end

 
  def shortlist?
    !moderator? && host?
  end

  def reject?
    !moderator? && host?
  end

  def accept?
    !moderator? && host?
  end

  def withdraw?
    applicant?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if moderator?
        scope.all
      elsif signed_in?
        base = scope.joins(listing: :property)
        base.where(applicant_id: user.id).or(base.where(properties: { owner_id: user.id }))
      else
        scope.none
      end
    end
  end

  private

  def applicant?
    signed_in? && record.applicant_id == user.id
  end

  def host?
    signed_in? && record.listing&.property&.owner_id == user.id
  end
end