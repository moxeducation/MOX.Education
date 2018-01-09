class Invitation < Membership
  scope :pending, -> { where(accepted: false) }
end
