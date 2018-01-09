class Group < ActiveRecord::Base
  belongs_to :admin, class_name: 'User'
  has_many :invitations, -> { where(accepted: false) }, dependent: :destroy
  has_many :applications, -> { where(accepted: false) }, dependent: :destroy
  has_many :memberships, -> { where(accepted: true) }, dependent: :destroy
  has_many :users, through: :memberships
  has_many :products, dependent: :destroy

  has_attached_file :picture, styles: {
      large: ['800x800#', :jpg],
      small: ['140x140#', :jpg]
  }, default_url: ''
  validates_attachment_content_type :picture, content_type: /\Aimage\/.*\Z/

  validates :name, :admin, presence: true

  def self.not_associated_with_user(user)
    user_relations = user.memberships | user.invitations | user.applications
    related_groups_ids = user_relations.map(&:group).map(&:id)
    Group.where.not(id: related_groups_ids, admin_id: user.id)
  end

  def has_application_from?(user)
    applications.where(user: user).any?
  end

  def has_invitation_to?(user)
    invitations.where(user: user).any?
  end

  def has_member?(user)
    users.include?(user) || admin?(user)
  end

  def admin?(user)
    admin == user
  end
end
