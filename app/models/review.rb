class Review < ApplicationRecord
    belongs_to :visit
    belongs_to :reviewer, class_name: "User"
    belongs_to :property
end