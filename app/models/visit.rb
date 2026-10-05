class Visit < ApplicationRecord
    belongs_to :application
    has_one :review

    enum :status, {
        proposed: "proposed",
        confirmed: "confirmed",
        cancelled: "cancelled",
        completed: "completed"
  }, validate: true

    validates :application_id, uniqueness: true
    validates :scheduled_at, presence: true
    validate :scheduled_after_application

    private

    def scheduled_after_application
        return if scheduled_at.blank? || application&.created_at.blank?

        if scheduled_at <= application.created_at
            errors.add(:scheduled_at, "must be after the application was created")
        end
    end
end