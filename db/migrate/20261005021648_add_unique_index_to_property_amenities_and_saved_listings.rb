class AddUniqueIndexToPropertyAmenitiesAndSavedListings < ActiveRecord::Migration[8.1]
  def change
    add_index :property_amenities, [:property_id, :amenity_id], unique: true
    add_index :saved_listings, [:user_id, :listing_id], unique: true  
  end
end
