class Listing < ApplicationRecord
    belongs_to :property

    has_many :listing_photos
    has_many :applications
    has_many :saved_listings
    has_many :reports
    
    enum :status, {
        draft: "draft",
        published: "published",
        reserved: "reserved",
        rented: "rented",
        withdrawn: "withdrawn"
    }, validate: true

    validates :title, :available_from, presence: true

    validates :monthly_rent,
        numericality: { greater_than: 0 }

    validate :availability_cannot_be_in_the_past

    scope :under_rent, ->(maximum_rent) {
        where("monthly_rent <= ?", maximum_rent)
    }
    scope :available_by, ->(move_in_date) {
        where("available_from <= ?", move_in_date)
    }
    scope :in_neighborhood, ->(neighborhood_id) {
        joins(:property).where(properties: { neighborhood_id: neighborhood_id })
    }
    scope :with_amenity, ->(amenity_id) {
        joins(property: :amenities).where(amenities: { id: amenity_id }).distinct
    }
    
    private

    def availability_cannot_be_in_the_past
        return if available_from.blank?

        if available_from < Date.current
            errors.add(:available_from, "cannot be in the past")
        end
    end
end