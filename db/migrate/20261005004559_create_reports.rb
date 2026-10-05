class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :listing, null: false, foreign_key: true
      t.text :reason, null: false
      t.string :status, null: false
      t.references :moderator, foreign_key: { to_table: :users }
      t.text :moderator_notes 
      t.datetime :created_at, null: false
      t.datetime :reviewed_at
      #t.timestamps
    end
  end
end
