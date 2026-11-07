class ListingPolicy < ApplicationPolicy
  def index?
    true
  end

  
  def show?
    !record.draft? || owner? || moderator?
  end

  def create?
    signed_in?
  end

  def update?
    owner? || moderator?
  end

  def destroy?
    owner? || moderator?
  end

  
  def publish?
    update?
  end

  def withdraw?
    update?
  end

  def mark_rented?
    update?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if moderator?
        scope.all
      elsif signed_in?
        base = scope.joins(:property)
        base.where.not(status: :draft).or(base.where(properties: { owner_id: user.id }))
      else
        scope.where.not(status: :draft)
      end
    end
  end

  private

  def owner?
    signed_in? && record.property&.owner_id == user.id
  end
end