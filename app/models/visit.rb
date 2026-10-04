class Vist < ApplicationRecord
    belongs_to :application

    has_one :review
end