class Application < ApplicationRecord
    belongs_to :listing
    belongs_to :applicant, class_name: "User"
    has_one :visit

    enum :status, {
        pending: "pending",
        shortlisted: "shortlisted",
        accepted: "accepted",
        rejected: "rejected",
        withdrawn: "withdrawn"
    }, validate: true

    validates :message, :move_in_date, :stay_length, presence: true

    validates :stay_length, numericality: { greater_than: 0 }

    validates :applicant_id,
        uniqueness: { scope: :listing_id }

    validate :cannot_apply_to_own_listing
    validate :listing_must_be_published, on: :create
    validate :move_in_date_cannot_be_in_the_past, if: :will_save_change_to_move_in_date?

    private

    def cannot_apply_to_own_listing
        return if listing.blank? || applicant_id.blank?

        if listing.property&.owner_id == applicant_id
            errors.add(:applicant, "cannot apply to their own listing")
        end
    end

    def listing_must_be_published
        return if listing.blank?

        unless listing.published?
            errors.add(:listing, "must be published to receive applications")
        end
    end

    def move_in_date_cannot_be_in_the_past
        return if move_in_date.blank?

        if move_in_date < Date.current
            errors.add(:move_in_date, "cannot be in the past")
        end
    end
end