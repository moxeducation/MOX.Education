class Application < Membership
  scope :pending, -> { where(accepted: false) }
end
