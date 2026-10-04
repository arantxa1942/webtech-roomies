class Saved_listing < ApplicationRecord
    belongs_to :user
    belongs_to :listing
end