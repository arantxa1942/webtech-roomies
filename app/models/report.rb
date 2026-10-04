class Report < ApplicationRecord
    belongs_to :reproter, class_name: "User"
    belongs_to :listing
    belongs_to :moderator, class_name: "User", optional: true
end