class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
    end

    add_attachment :tags, :image

    create_table :tags_products, id: false do |t|
      t.belongs_to :tag, index: true
      t.belongs_to :product, index: true
    end
  end
end
