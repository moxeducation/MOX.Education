require 'rails_helper'

RSpec.describe Membership, type: :model do
  context 'validations' do
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:user) }
  end
end
