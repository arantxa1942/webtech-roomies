class Property < ApplicationRecord
  PROPERTY_TYPES = %w[apartment house studio room].freeze

  belongs_to :owner, class_name: "User"
  belongs_to :neighborhood

  has_many :listings, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy
  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities

  validates :title, :address, presence: true
  validates :property_type, inclusion: { in: PROPERTY_TYPES }, allow_blank: true
  validates :bedrooms, numericality: { only_integer: true, greater_than: 0 }
  validates :bathrooms, numericality: { only_integer: true, greater_than: 0 }
  validates :shared_spaces, inclusion: { in: [ true, false ] }
end
