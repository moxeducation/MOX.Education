require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:product) { FactoryGirl.create :product }

  it 'there should be zero published products' do
    Product.unscoped.where(public: true).count == 0
  end

  context 'published count' do
    subject { Product.published(product.slug).count }

    it { is_expected.to eq(0) }
  end

  context 'published' do
    before { product.publish! }

    it 'there should be one published product' do
      Product.unscoped.where(public: true).count == 1
    end

    context 'published count' do
      subject { Product.published(product.slug).count }

      it { is_expected.to eq(1) }
    end
  end
end
