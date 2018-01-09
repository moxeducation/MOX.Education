require 'rails_helper'

RSpec.describe PublicProductsController, type: :controller do
  let(:product) { create :product }

  before { product.publish! }

  subject { response }

  describe '#show' do
    let(:params) { { slug: product.slug } }

    after { get :show, params }

    it { expect(Product).to receive(:published) }
  end
end
