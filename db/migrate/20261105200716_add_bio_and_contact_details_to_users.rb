class AddBioAndContactDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :bio, :text
    add_column :users, :contact_details, :string
  end
end
