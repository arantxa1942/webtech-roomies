class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  has_many :properties, foreign_key: "owner_id", dependent: :destroy
  has_many :listings, dependent: :destroy
end