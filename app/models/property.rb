class Property < ApplicationRecord
    belongs_to :owner, class_name: "User"
    belongs_to :neighborhood

    has_many :listings
    has_many :reviews
    has_many :property_amenities
    has_many :amenities, through: :property_amenities

    validates :title, :address, presence: true

    validates :bedrooms, numericality: {
                only_integer: true,
                greater_than: 0
            }

    validates :bathrooms, numericality: {
                only_integer: true,
                greater_than: 0
            }

    validates :shared_spaces, inclusion: { in: [true, false] }
end