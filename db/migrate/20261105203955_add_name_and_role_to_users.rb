class AddNameAndRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    unless column_exists?(:users, :full_name)
      add_column :users, :full_name, :string
    end

    unless column_exists?(:users, :role)
      add_column :users, :role, :string
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "These columns may have existed before this migration"
  end
end
