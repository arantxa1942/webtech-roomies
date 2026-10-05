class Report < ApplicationRecord
    belongs_to :reporter, class_name: "User"
    belongs_to :listing
    belongs_to :moderator, class_name: "User", optional: true

    validates :reason, :status, :presence: true
end