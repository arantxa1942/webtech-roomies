class PropertyPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def owner?
    signed_in? && record.owner_id == user.id
  end
end