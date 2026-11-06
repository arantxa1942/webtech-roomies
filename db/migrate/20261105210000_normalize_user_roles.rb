class NormalizeUserRoles < ActiveRecord::Migration[8.1]
  def up
    # Older seeds stored "host"/"seeker"; the only roles now are member and moderator.
    execute "UPDATE users SET role = 'member' WHERE role IS NULL OR role NOT IN ('member', 'moderator')"
    change_column_default :users, :role, from: nil, to: "member"
    change_column_null :users, :role, false
  end

  def down
    change_column_null :users, :role, true
    change_column_default :users, :role, from: "member", to: nil
  end
end
