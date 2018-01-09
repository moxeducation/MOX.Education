require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:group) { create(:group) }

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:admin) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:products) }
    it { is_expected.to belong_to(:admin) }
  end

  context 'with application' do

  end
end
