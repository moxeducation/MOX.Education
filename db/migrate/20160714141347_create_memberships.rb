class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.string :type
      t.boolean :accepted, null: false, default: false
      t.belongs_to :user, null: false
      t.belongs_to :group, null: false
      t.timestamps null: false
    end
  end
end
