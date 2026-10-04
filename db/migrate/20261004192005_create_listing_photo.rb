class CreateListingPhoto < ActiveRecord::Migration[8.1]
  def change
    create_table :listing_photos do |t|
      t.references :listing, null: false, foreign_key: true 
      t.integer :image_url, null: false 
      t.boolean :is_main, null: false, default: false 
      #t.timestamps
    end
  end
end
