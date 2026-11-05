<<<<<<< HEAD
class User < ApplicationRecord
    has_many :properties, foreign_key: :owner_id
    has_many :applications, foreign_key: :applicant_id
    has_many :reviews, foreign_key: :reviewer_id
    has_many :saved_listings
    has_many :reports, foreign_key: :reporter_id
    has_many :moderated_reports, class_name: "Report", foreign_key: :moderator_id

    validates :email, :password_hash, :full_name, presence: true
    validates :email, uniqueness: true
    validates :role, inclusion: { in: [ "host", "seeker", "member", "moderator" ] }
end
=======
class User < ApplicationRecord
  has_many :properties, foreign_key: :owner_id
  has_many :applications, foreign_key: :applicant_id 
  has_many :reviews, foreign_key: :reviewer_id
  has_many :saved_listings
  has_many :reports, foreign_key: :reporter_id
  has_many :moderated_reports , class_name: "Report", foreign_key: :moderator_id
  
  # Usamos has_secure_password estándar y mapeamos password_hash
  has_secure_password validations: true

  validates :email, :password_hash, :full_name, presence: true
  validates :email, uniqueness: true
  validates :role, inclusion: { in: ["host", "seeker", "member", "moderator"] }

  # Mapea password_digest de has_secure_password a tu columna password_hash en la base de datos
  def password_digest
    password_hash
  end

  def password_digest=(digest)
    self.password_hash = digest
  end
end
>>>>>>> f85dde4 (Assignment 4)
