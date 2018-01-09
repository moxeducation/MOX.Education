class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates :group, :user, presence: true

  scope :pending,  -> { where(accepted: false) }
  scope :accepted, -> { where(accepted: true) }

  def self.create_if_not_exists(params)
    Membership.where(params).any? ? false : create(params)
  end

  def accept!
    update_attributes! accepted: true
  end
end
