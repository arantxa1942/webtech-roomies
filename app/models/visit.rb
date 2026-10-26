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
    validate :application_must_be_shortlisted, on: :create
    validate :scheduled_cannot_be_in_the_past, if: :will_save_change_to_scheduled_at?
    validate :application_must_be_shortlisted
    def application_must_be_shortlisted
      return if application.blank?

      unless application.shortlisted?
        errors.add(:application, "must be shortlisted before proposing a visit")
      end
    end

    private
    def application_must_be_shortlisted
        return if application.blank?

        unless application.shortlisted?
            errors.add(:application, "must be shortlisted before proposing a visit")
        end
    end
    def scheduled_cannot_be_in_the_past
        return if scheduled_at.blank?

        if scheduled_at <= Time.current
            errors.add(:scheduled_at, "cannot be in the past")
        end
    end
end