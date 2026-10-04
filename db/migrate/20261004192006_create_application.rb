class CreateApplication < ActiveRecord::Migration[8.1]
  def change
    create_table :applications do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :applicant, null: false, foreign_key: {to_table: :users}
      t.text :message
      t.string :status, null: false, default: "pending"
      t.timestamps
    end
  end
end
