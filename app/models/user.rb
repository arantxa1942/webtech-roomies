class User < ApplicationRecord
    has_many :properties, foreign_key: :owner_id
    has_many :applications, foreign_key: :applicant_id 
    has_many :reviews, foreign_key: :reviewer_id
    has_many :saved_listings
    has_many :reports, foreign_key: :reporter_id
    has_many :moderated_reports , class_name: "Report", foreign_key: :moderator_id

    validates :email, :password_hash, :full_name, presence: true
    validates :email, uniqueness: true
    validates :role, inclusion: { in: ["member", "moderator"] }
end