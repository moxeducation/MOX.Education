class AddGroupToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :group, index: true, null: true
  end
end
