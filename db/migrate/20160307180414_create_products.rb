class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :user

      t.string :title
      t.integer :approver_id
      t.integer :order

      t.timestamps
    end

    add_attachment :products, :image
  end
end
