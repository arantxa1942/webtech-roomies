class ListingPhoto < ApplicationRecord
    belongs_to :listing

    validates :image_url, presence: true
    validates :is_main, inclusion: { in: [true, false] }
end