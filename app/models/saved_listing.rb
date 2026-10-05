class SavedListing < ApplicationRecord
    belongs_to :user
    belongs_to :listing

    validates :saved_at, presence: true
    validates :listing_id, uniqueness: { scope: :user_id }
end