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
    validates :message, presence: true

    validates :applicant_id,
        uniqueness: { scope: :listing_id }

    validate :cannot_apply_to_own_listing
    validate :listing_must_be_published, on: :create

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
end