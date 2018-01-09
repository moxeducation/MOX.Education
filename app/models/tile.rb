# == Schema Information
#
# Table name: tiles
#
#  id                :integer          not null, primary key
#  product_id        :integer
#  tile_type         :string(255)      default("text")
#  title             :string(255)
#  title_color       :string(255)
#  color             :string(255)
#  content           :text(65535)
#  order             :integer
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#  linked_product_id :integer
#

class Tile < ActiveRecord::Base
  belongs_to :product
  belongs_to :linked_product, class_name: 'Product'

  default_scope -> { order(order: :asc) }
  scope :approved, -> { joins(:product).where.not(products: { approver_id: nil }) }
  scope :disapproved, -> { joins(:product).where(products: { approver_id: nil }) }
  scope :random, -> { order('RAND()') }

  after_save :update_product

  has_attached_file :file, styles: {
    large: ['800x800#', :jpg],
    medium: ['200x200#', :jpg],
    small: ['100x100#', :jpg]
  }, default_url: '', processors: lambda {|x|
    if x.file_content_type =~ /application\/pdf/
      [:ghostscript]
    elsif x.file_content_type =~ /video\/.*/
      [:transcoder]
    else
      [:thumbnail]
    end
  }

  validates_with AttachmentSizeValidator, attributes: :file, less_than: 300.megabytes
  validates_attachment :file, content_type: { content_type: /(image\/.*|video\/.*|application\/pdf)/ }

  attr_accessor :delete_file
  before_validation { file.clear if delete_file == '1' }

  before_save :detect_tile_type

  def linked?
    if self.linked_product_id.present? && self.linked_product_id != 0
      # loop protection
      product = self.linked_product
      while product
        return false if product.id == self.product_id
        product = product.tiles.first.try(:linked_product)
      end

      true
    end
  end

  def linked_product_tile
    (linked? && linked_product) ? linked_product.tiles.first : nil
  end

  def title
    linked_product_tile.title rescue super
  end

  def title_color
    linked_product_tile.title_color rescue super
  end

  def color
    linked_product_tile.color rescue super
  end

  def content
    linked_product_tile.content rescue super
  end

  def tile_type
    linked_product_tile.tile_type rescue super
  end

  alias_method :original_file, :file
  def file
    linked_product_tile.file rescue self.original_file
  end

  def file_content_type
    linked_product_tile.file_content_type rescue super
  end

  def content= value
    super ActionController::Base.helpers.sanitize(value, tags: %w(a abbr acronym address area b bdo big blockquote br button caption center cite code col colgroup dd del dfn dir div dl dt em fieldset font form h1 h2 h3 h4 h5 h6 hr i img input ins kbd label legend li map menu ol optgroup option p pre q s samp select small span strike strong sub sup table tbody td textarea tfoot th thead u tr tt u ul var>), attributes: %w(href style width height src alt title))
  end

  def title= value
    super ActionController::Base.helpers.strip_tags(value)
  end

  def linked_product_id= value
    super (value == self.product_id ? nil : value)
  end

  def content_formatted
    case tile_type
    when 'video_external'
      video = VideoInfo.new ActionController::Base.helpers.strip_tags(content).strip
      video.embed_code
    when 'video_internal'
      ActionController::Base.helpers.videojs_rails sources: { mp4: file.to_s }
    else
      content
    end
  end

  protected

  def detect_tile_type
    video = VideoInfo.new ActionController::Base.helpers.strip_tags(content).strip rescue nil
    if linked_product_tile
      self.tile_type = 'product'
    elsif video
      self.tile_type = 'video_external'
      self.file = open(video.thumbnail_large) if video.thumbnail_large && self.file.blank?
    elsif file_content_type =~ /image\/.*/
      self.tile_type = 'image'
    elsif file_content_type =~ /application\/pdf/
      self.tile_type = 'pdf'
    elsif file_content_type =~ /video\/.*/
      self.tile_type = 'video_internal'
    elsif link?
      self.tile_type = 'website'
      File.open('screenshot-tmp.png', "wb") do |file|
        file.write open("http://mini.s-shot.ru/800x800/800/png/?#{ActionController::Base.helpers.strip_tags(content).strip}").read
      end
      self.file = File.open('screenshot-tmp.png')
      self.content = ActionController::Base.helpers.strip_tags(content).strip
    else
      self.tile_type = 'text'
    end

    self.tile_type
  end

  def link?
    /\Ahttp(s)?:\/\//.match(ActionController::Base.helpers.strip_tags(content).strip)
  end

  def update_product
    product.touch
    product.save
  end
end
