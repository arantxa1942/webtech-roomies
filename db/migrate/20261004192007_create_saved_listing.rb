class CreateSavedListing < ActiveRecord::Migration[8.1]
  def change
    create_table :saved_listings do |t|
      t.references :user,    null: false, foreign_key: true
      t.references :listing, null: false, foreign_key: true
      t.datetime :saved_at, null: false 
      #t.timestamps
    end
  end
end
