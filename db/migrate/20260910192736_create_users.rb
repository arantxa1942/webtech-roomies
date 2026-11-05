class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:users)
      create_table :users do |t|
        t.string :email_address, null: false
        t.string :password_digest, null: false
        t.timestamps
      end
      add_index :users, :email_address, unique: true
    else
      unless column_exists?(:users, :email_address)
        add_column :users, :email_address, :string, default: "", null: false
      end
      unless column_exists?(:users, :password_digest)
        add_column :users, :password_digest, :string, default: "", null: false
      end

      reversible do |dir|
        dir.up do
          execute("UPDATE users SET email_address = 'user_' || id || '@example.com' WHERE email_address = '' OR email_address IS NULL")
        end
      end

      unless index_exists?(:users, :email_address)
        add_index :users, :email_address, unique: true
      end
    end
  end
end