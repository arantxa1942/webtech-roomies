class DropListingPhotosTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :listing_photos if table_exists?(:listing_photos)
  end
end
