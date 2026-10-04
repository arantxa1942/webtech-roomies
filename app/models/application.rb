class Application < ApplicationRecord
    belongs_to :listing
    belongs_to :applicant, class_name: "User"

    has_one :visit
end