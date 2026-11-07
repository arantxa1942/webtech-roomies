class UserPolicy < ApplicationPolicy
  
  def update?
    signed_in? && record == user
  end
end