class AddLinkedProductToTiles < ActiveRecord::Migration
  def change
    add_column :tiles, :linked_product_id, :integer
  end
end
