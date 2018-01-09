class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.belongs_to :admin, class_name: 'User'
      t.timestamps null: false
    end
  end
end
