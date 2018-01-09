FactoryGirl.define do
  sequence :order do |n|
    -n
  end

  factory :product do
    slug { FFaker::Internet.slug }
    association :approver, factory: :admin
    association :user
    order
    ready_for_approve { true }
  end

  trait :with_tiles do
    after :create do |product|
      FactoryGirl.create_list :tile, 3, product: product
    end
  end
end
