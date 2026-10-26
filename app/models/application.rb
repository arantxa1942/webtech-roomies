class Application < ApplicationRecord
  belongs_to :listing
  belongs_to :applicant, class_name: "User"
  has_one :visit, dependent: :destroy

  enum :status, {
    pending: "pending",
    shortlisted: "shortlisted",
    accepted: "accepted",
    rejected: "rejected",
    withdrawn: "withdrawn"
  }, validate: true

  validates :message, :move_in_date, :stay_length, presence: true
  validates :stay_length, numericality: { only_integer: true, greater_than: 0 }
  validates :applicant_id, uniqueness: { scope: :listing_id, message: "has already applied to this listing" }

  validate :cannot_apply_to_own_listing
  validate :listing_must_accept_applications, on: :create
  validate :move_in_date_cannot_be_in_the_past, if: :will_save_change_to_move_in_date?
  validate :only_one_accepted_per_listing, if: :accepted?

  def shortlist!
    transition_to!(:shortlisted, from: %w[pending])
  end

  def reject!
    transition_to!(:rejected, from: %w[pending shortlisted])
  end

  def withdraw!
    transition_to!(:withdrawn, from: %w[pending shortlisted])
  end

  def accept!
    transaction do
      listing.lock!
      fail_transition!("Only pending or shortlisted applications can be accepted") unless pending? || shortlisted?
      fail_transition!("The listing must be published to accept an applicant") unless listing.published?

      update!(status: :accepted)

      listing.applications
             .where(status: %w[pending shortlisted])
             .where.not(id: id)
             .find_each { |other| other.update!(status: :rejected) }

      listing.update!(status: :reserved)
    end
  end

  private

  def transition_to!(new_status, from:)
    fail_transition!("Cannot change status from #{status} to #{new_status}") unless status.in?(from)
    update!(status: new_status)
  end

  def fail_transition!(message)
    errors.add(:status, message)
    raise ActiveRecord::RecordInvalid, self
  end

  def listing_must_accept_applications
    return if listing.blank?
    errors.add(:listing, "is not accepting applications") unless listing.published?
  end

  def cannot_apply_to_own_listing
    return if listing.blank? || applicant_id.blank?
    errors.add(:applicant, "cannot apply to their own listing") if listing.property&.owner_id == applicant_id
  end

  def only_one_accepted_per_listing
    return if listing.blank?
    if listing.applications.accepted.where.not(id: id).exists?
      errors.add(:base, "This listing already has an accepted application")
    end
  end

  def move_in_date_cannot_be_in_the_past
    return if move_in_date.blank?
    errors.add(:move_in_date, "cannot be in the past") if move_in_date < Date.current
  end
end
