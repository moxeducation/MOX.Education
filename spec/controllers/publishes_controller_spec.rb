require 'rails_helper'

RSpec.describe PublishesController, type: :controller do
  let(:user) { create :user }
  let(:product) { create :product }

  subject { response }

  before { sign_in user }

  describe '#create' do
    let(:params) { { product_id: product.id } }

    context 'when product receives publish' do
      after { post :create, params }

      it { expect_any_instance_of(Product).to receive(:publish!) }
    end

    context 'when controller responds OK' do
      before { post :create, params }

      it { is_expected.to have_http_status(:success) }
    end
  end
end
