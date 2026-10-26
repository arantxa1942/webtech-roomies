class AddTimestampsAndStatusToVisits < ActiveRecord::Migration[8.0]
  def change
    add_column :visits, :status, :string, default: "proposed" unless column_exists?(:visits, :status)

    unless column_exists?(:visits, :created_at)
      # Agregamos los timestamps permitiendo nulos temporalmente para registros antiguos
      add_timestamps :visits, null: true

      # Rellenamos los registros antiguos con la hora actual
      reversible do |dir|
        dir.up do
          execute("UPDATE visits SET created_at = CURRENT_TIMESTAMP WHERE created_at IS NULL")
          execute("UPDATE visits SET updated_at = CURRENT_TIMESTAMP WHERE updated_at IS NULL")
        end
      end
    end
  end
end
