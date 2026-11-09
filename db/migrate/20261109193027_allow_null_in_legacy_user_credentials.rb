class AllowNullInLegacyUserCredentials < ActiveRecord::Migration[8.1]
  def up
    if column_exists?(:users, :email)
      change_column_null :users, :email, true
    end

    if column_exists?(:users, :password_hash)
      change_column_null :users, :password_hash, true
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "New accounts do not populate legacy credentials"
  end
end