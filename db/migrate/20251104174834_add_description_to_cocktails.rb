class AddDescriptionToCocktails < ActiveRecord::Migration[7.0]
  def change
    add_column :cocktails, :description, :text
  end
end
