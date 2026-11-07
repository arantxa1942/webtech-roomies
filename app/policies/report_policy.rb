class ReportPolicy < ApplicationPolicy
  def create?
    signed_in?
  end

  def index?
    moderator?
  end

  def resolve?
    moderator?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      moderator? ? scope.all : scope.none
    end
  end
end