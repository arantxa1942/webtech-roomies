class Review < ApplicationRecord
    belongs_to :visit
    belongs_to :reviewer, class_name: "User"
    belongs_to :property

    validates :visit_id, uniqueness: true
    validates :comment, presence: true
    validates :rating, numericality: {
                    only_integer: true,
                    greater_than_or_equal_to: 1,
                    less_than_or_equal_to: 5
                }

    validate :visit_must_be_completed
    validate :reviewer_must_match_applicant
    validate :property_must_match_visit
    validate :cannot_review_own_property

    private

    def visit_must_be_completed
        return if visit.blank?

        unless visit.completed?
            errors.add(:visit, "must be completed before leaving a review")
        end
    end

    def reviewer_must_match_applicant
        return if visit&.application.blank? || reviewer_id.blank?

        if reviewer_id != visit.application.applicant_id
            errors.add(:reviewer, "must be the applicant who visited")
        end
    end

    def property_must_match_visit
        return if visit&.application&.listing.blank? || property_id.blank?

        if property_id != visit.application.listing.property_id
            errors.add(:property, "must match the property visited")
        end
    end

    def cannot_review_own_property
        return if property.blank? || reviewer_id.blank?

        if reviewer_id == property.owner_id
            errors.add(:reviewer, "cannot review their own property")
        end
    end
end