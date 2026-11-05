class ApplicationNotificationJob < ApplicationJob
  queue_as :default

  def perform(application_id)
    application = Application.find_by(id: application_id)
    RoomMailer.application_status_changed(application).deliver_now if application.present?
  end
end