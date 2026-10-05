class Neighborhood < ApplicationRecord
    has_many :properties

    validates :name, :city, presence: true
    validates :name, uniqueness: { scope: :city }
end
