class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  after_action :verify_authorized
  after_action :verify_policy_scoped, if: -> { action_name == "index" }
  
  private

  def current_user
    Current.user
  end

  def pundit_user
    Current.user
  end

  def user_not_authorized(exception)
    return request_authentication unless authenticated?

    action = exception.query.to_s.delete_suffix("?")
    model  = exception.record.is_a?(Class) ? exception.record : exception.record.class
    @message = "You are not allowed to #{action} this #{model.model_name.human.downcase}."
    render "errors/forbidden", status: :forbidden
  end

  def record_not_found
    render "errors/not_found", status: :not_found
  end
end