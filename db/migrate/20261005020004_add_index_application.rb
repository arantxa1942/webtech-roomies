class AddIndexApplication < ActiveRecord::Migration[8.1]
  def change
    add_index :applications, [:listing_id, :applicant_id], unique: true
  end
end
