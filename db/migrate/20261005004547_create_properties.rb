class CreateProperties < ActiveRecord::Migration[8.1]
  def change
    create_table :properties do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :neighborhood, null: false, foreign_key: true
      t.string :title, null: false
      t.string :address, null: false
      t.text :description
      t.integer :bedrooms, null: false
      t.integer :bathrooms, null: false
      t.boolean :shared_spaces, default: true
      t.datetime :created_at, null: false
      #t.timestamps
    end
  end
end
