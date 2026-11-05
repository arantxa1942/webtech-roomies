class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :listing
  belongs_to :moderator, class_name: "User", optional: true

  enum :status, {
    pending: "pending",
    reviewed: "reviewed",
    dismissed: "dismissed"
  }, validate: true

  validates :reason, presence: true
end