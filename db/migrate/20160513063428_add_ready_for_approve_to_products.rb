class AddReadyForApproveToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ready_for_approve, :boolean
  end
end
