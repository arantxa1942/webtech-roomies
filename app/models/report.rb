class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :listing
  belongs_to :moderator, class_name: "User", optional: true

  enum :status, {
    pending: "pending",
    reviewed: "reviewed",
    dismissed: "dismissed"
  }, default: :pending, validate: true

  validates :reason, presence: true, length: { minimum: 10, maximum: 1000 }

  def resolve!(moderator:, status:, notes: nil)
    fail_resolution!("has already been resolved") unless pending?
    fail_resolution!("must be reviewed or dismissed") unless status.to_s.in?(%w[reviewed dismissed])

    update!(status: status, moderator: moderator, moderator_notes: notes, reviewed_at: Time.current)
  end

  private

  def fail_resolution!(message)
    errors.add(:status, message)
    raise ActiveRecord::RecordInvalid, self
  end
end