class Listing < ApplicationRecord
    belongs_to :property

    has_many :listing_photos
    has_many :applications
    has_many :saved_listings
end