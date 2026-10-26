class Neighborhood < ApplicationRecord
    has_many :properties, dependent: :restrict_with_error

    validates :name, :city, presence: true
    validates :name, uniqueness: { scope: :city }
end
