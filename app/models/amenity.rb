class Amenity < ApplicationRecord
    has_many :property_amenities
    has_many :properties, through: :property_amenities
end