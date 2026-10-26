class Listing < ApplicationRecord
  MAX_PHOTO_SIZE = 5.megabytes
  ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze

  belongs_to :property

  has_many :applications, dependent: :restrict_with_error
  has_many :saved_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  has_many_attached :photos do |attachable|
    attachable.variant :card,  resize_to_fill: [ 400, 300 ]
    attachable.variant :large, resize_to_limit: [ 1200, 900 ]
  end

  has_rich_text :description
  has_rich_text :house_rules

  enum :status, {
    draft: "draft",
    published: "published",
    reserved: "reserved",
    rented: "rented",
    withdrawn: "withdrawn"
  }, validate: true

  validates :title, :available_from, presence: true
  validates :monthly_rent, numericality: { greater_than: 0 }
  validates :deposit, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stay, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  validate :availability_cannot_be_in_the_past, if: :will_save_change_to_available_from?
  validate :photos_must_be_valid_images

  scope :under_rent, ->(maximum_rent) { where("monthly_rent <= ?", maximum_rent) }
  scope :available_by, ->(move_in_date) { where("available_from <= ?", move_in_date) }
  scope :in_neighborhood, ->(neighborhood_id) {
    joins(:property).where(properties: { neighborhood_id: neighborhood_id })
  }
  scope :with_amenity, ->(amenity_id) {
    joins(property: :amenities).where(amenities: { id: amenity_id }).distinct
  }
  def publish!
    transition_to!(:published, from: %w[draft])
  end

  def withdraw!
    transition_to!(:withdrawn, from: %w[draft published reserved])
  end

  def mark_rented!
    transition_to!(:rented, from: %w[reserved])
  end

  private
   def transition_to!(new_status, from:)
    unless status.in?(from)
      errors.add(:status, "cannot change from #{status} to #{new_status}")
      raise ActiveRecord::RecordInvalid, self
    end
    update!(status: new_status)
  end

  def availability_cannot_be_in_the_past
    return if available_from.blank?

    if available_from < Date.current
      errors.add(:available_from, "cannot be in the past")
    end
  end

  def photos_must_be_valid_images
    photos.each do |photo|
      unless photo.content_type.in?(ALLOWED_PHOTO_TYPES)
        errors.add(:photos, "#{photo.filename} must be a JPEG, PNG or WEBP image")
      end

      if photo.byte_size > MAX_PHOTO_SIZE
        errors.add(:photos, "#{photo.filename} must be smaller than 5 MB")
      end
    end
  end
end
