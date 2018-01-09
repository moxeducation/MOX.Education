# == Schema Information
#
# Table name: products
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  title              :string(255)
#  approver_id        :integer
#  order              :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  slug               :string(255)
#  ready_for_approve  :boolean
#

class Product < ActiveRecord::Base
  attr_accessor :editable

  belongs_to :user
  belongs_to :approver, class_name: 'User'
  belongs_to :group
  has_many :tiles
  has_and_belongs_to_many :tags, join_table: 'tags_products'

  before_save :generate_slug

  default_scope -> { includes(:tiles, :tags).order(approver_id: :desc, order: :asc) }
  scope :shared, -> { where(group: nil) }
  scope :approved, -> { where.not(approver_id: nil) }
  scope :disapproved, -> { where(approver_id: nil) }
  scope :for_user, -> (user_id) { where('(approver_id IS NOT NULL OR user_id = ?)', user_id) }

  accepts_nested_attributes_for :tiles

  def approved?
    !approver_id.nil?
  end

  def update_slug
    update_attribute :slug, generate_slug
  end

  def publish!
    update(public: true)
  end

  def self.published(slug)
    unscoped.where(slug: slug, public: true)
  end

  protected

  def generate_slug
    return unless slug.blank?

    self.slug = nil and return nil if tiles.empty?

    new_slug = tiles.first.title.to_s.strip

    new_slug.gsub!(/['`]/, '')
    new_slug.gsub!(/\s*@\s*/, ' at ')
    new_slug.gsub!(/\s*&\s*/, ' and ')
    new_slug.gsub!(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
    new_slug.gsub!(/_+/, '_')
    new_slug.gsub!(/\A[_\.]+|[_\.]+\z/, '')

    new_slug = "product_#{self.id}" if new_slug.blank?

    counter = 1
    counter_str = ''
    until Product.where(slug: new_slug + counter_str).where.not(id: self.id).empty?
      counter += 1
      counter_str = "_#{counter}"
    end

    self.slug = new_slug + counter_str
  end
end
