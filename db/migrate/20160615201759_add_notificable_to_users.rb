class AddNotificableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notificable, :boolean, default: true
  end
end
