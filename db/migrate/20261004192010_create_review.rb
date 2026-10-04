class CreateReview < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :visit, null: true, foreign_key: true, index: { unique: true }
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :property, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment
      t.datetime :created_at, null: false
      #t.timestamps
    end
  end
end
