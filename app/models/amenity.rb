class Amenity < ApplicationRecord
  has_many :property_amenities, dependent: :restrict_with_error
  has_many :properties, through: :property_amenities

  validates :name, :category, presence: true
end