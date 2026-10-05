class MakeApplicationUniqueVisits < ActiveRecord::Migration[8.1]
  def change
    remove_index :visits, :application_id
    add_index :visits, :application_id, unique: true
  end
end
