class AddUserIdAndApprovedToTags < ActiveRecord::Migration
  def change
    add_column :tags, :user_id, :integer
    add_column :tags, :approved, :boolean, default: false
    add_index :tags, :user_id
    add_index :tags, :approved

    Tag.all.update_all approved: true
  end
end
