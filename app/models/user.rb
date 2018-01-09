# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  company_name           :string(255)
#  role                   :string(255)      default("user")
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  notificable            :boolean          default(TRUE)
#

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ROLES = %w(user admin)

  scope :admins, -> { where(role: 'admin') }
  scope :notificable, -> { where(notificable: true) }

  has_many :products, :dependent => :destroy
  has_many :tiles, through: :products, :dependent => :destroy

  has_many :own_groups, class_name: 'Group', foreign_key: 'admin_id'
  has_many :memberships, -> { where(accepted: true) }
  has_many :invitations, -> { where(accepted: false) }
  has_many :applications, -> { where(accepted: false) }
  has_many :groups, through: :memberships

  validates_presence_of :company_name
  validates_inclusion_of :role, in: ROLES
  validates_confirmation_of :password, if: :encrypted_password_changed?

  before_save :set_default_role

  def role?(role)
    [role].flatten.map{|x| x.to_s.split(/[\s,;]/)}.flatten.include?(self.role)
  end

  protected

  def set_default_role
    self.role = 'user' unless self.role.present?
  end
end
