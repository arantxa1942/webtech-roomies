class Visit < ApplicationRecord
  belongs_to :application
  has_one :review, dependent: :destroy

  enum :status, {
    proposed: "proposed",
    confirmed: "confirmed",
    cancelled: "cancelled",
    completed: "completed"
  }, default: :proposed, validate: true

  validates :application_id, uniqueness: true
  validates :scheduled_at, presence: true
  validate :application_must_be_shortlisted, on: :create
  validate :scheduled_cannot_be_in_the_past, if: :will_save_change_to_scheduled_at?

  def confirm!
    transition_to!(:confirmed, from: %w[proposed])
  end

  def cancel!
    transition_to!(:cancelled, from: %w[proposed confirmed])
  end

  def complete!
    transition_to!(:completed, from: %w[confirmed])
  end

  private

  def transition_to!(new_status, from:)
    unless status.in?(from)
      errors.add(:status, "cannot change from #{status} to #{new_status}")
      raise ActiveRecord::RecordInvalid, self
    end
    update!(status: new_status)
  end

  def application_must_be_shortlisted
    return if application.blank?
    errors.add(:application, "must be shortlisted before proposing a visit") unless application.shortlisted?
  end

  def scheduled_cannot_be_in_the_past
    return if scheduled_at.blank?
    errors.add(:scheduled_at, "cannot be in the past") if scheduled_at <= Time.current
  end
end
