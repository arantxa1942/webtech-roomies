class RoomMailer < ApplicationMailer
  def application_status_changed(application_record)
    @application = application_record
    mail to: @application.user.email_address, subject: "Your application status has changed"
  end
end