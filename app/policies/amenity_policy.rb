class AmenityPolicy < ApplicationPolicy
 
  def index?
    signed_in?
  end

  def show?
    signed_in?
  end

 
  def create?
    moderator?
  end

  def update?
    moderator?
  end

  def destroy?
    moderator?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end