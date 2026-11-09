class PropertyAmenityPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    manage_property?
  end

  def update?
    manage_property?
  end

  def destroy?
    manage_property?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def manage_property?
    signed_in? &&
      (moderator? || record.property&.owner_id == user.id)
  end
end