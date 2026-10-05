class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_hash, null: false
      t.string :full_name, null: false
      t.string :phone
      t.string :role, null: false, default: "member"
      t.datetime :created_at, null: false
      #t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
