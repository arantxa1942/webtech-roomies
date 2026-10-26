class RemoveDescriptionFromListings < ActiveRecord::Migration[8.1]
  def change
    remove_column :listings, :description, :text
  end
end
