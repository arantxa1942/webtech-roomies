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
    validate :scheduled_cannot_be_in_the_past, if: :will_save_change_to_scheduled_at?

    private

    def scheduled_cannot_be_in_the_past
        return if scheduled_at.blank?

        if scheduled_at <= Time.current
            errors.add(:scheduled_at, "cannot be in the past")
        end
    end
end