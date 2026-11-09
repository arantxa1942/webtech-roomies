class SavedListingPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

  def show?
    owner?
  end

  def create?
    owner? && record.listing&.published?
  end

  def destroy?
    owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      signed_in? ? scope.where(user_id: user.id) : scope.none
    end
  end

  private

  def owner?
    signed_in? && record.user_id == user.id
  end
end