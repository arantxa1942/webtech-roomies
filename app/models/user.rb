class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :properties, foreign_key: "owner_id", inverse_of: :owner, dependent: :destroy
  has_many :listings, through: :properties
  has_many :applications, foreign_key: "applicant_id", inverse_of: :applicant, dependent: :destroy

  # The "visitor" role is not a value: it is simply not being signed in.
  enum :role, { member: "member", moderator: "moderator" }, default: :member, validate: true

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :full_name, presence: true
  validates :email_address, presence: true, uniqueness: true,
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
