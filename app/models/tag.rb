# == Schema Information
#
# Table name: tags
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  user_id            :integer
#  approved           :boolean          default(FALSE)
#

class Tag < ActiveRecord::Base
  scope :for_user, -> (user) {
    if user
      if user.role? :admin
        order(:approved)
      else
        where('approved = ? OR user_id = ?', true, user.id).order(:approved)
      end
    else
      where(approved: true)
    end
  }

  has_and_belongs_to_many :products, join_table: 'tags_products'
  belongs_to :user

  has_attached_file :image, styles: {
    large: ['800x800#', :jpg],
    medium: ['200x200#', :jpg],
    small: ['100x100#', :jpg]
  }, default_url: ''

  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  validates_uniqueness_of :name
end
