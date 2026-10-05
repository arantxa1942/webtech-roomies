class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.references :property, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.decimal :monthly_rent, null: false
      t.date :available_from, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :created_at, null: false
      #t.timestamps
    end
  end
end
