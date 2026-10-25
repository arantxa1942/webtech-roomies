class AddDetailsToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :deposit, :decimal
    add_column :listings, :minimum_stay, :integer
    add_column :listings, :furnished, :boolean
    add_column :listings, :private_bathroom, :boolean
  end
end
