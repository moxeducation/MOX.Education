class AddPictureToGroup < ActiveRecord::Migration
  def up
    add_attachment :groups, :picture
  end

  def down
    remove_attachment :groups, :picture
  end
end
