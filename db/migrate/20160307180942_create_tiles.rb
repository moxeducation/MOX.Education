class CreateTiles < ActiveRecord::Migration
  def change
    create_table :tiles do |t|
      t.belongs_to :product

      t.string :tile_type, default: 'text'
      t.string :title
      t.string :title_color
      t.string :color
      t.text :content
      t.integer :order

      t.timestamps
    end

    add_index :tiles, :tile_type

    add_attachment :tiles, :file
  end
end
