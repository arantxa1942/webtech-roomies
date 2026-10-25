class AddDetailsToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :move_in_date, :date
    add_column :applications, :stay_length, :integer
  end
end
