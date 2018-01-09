FactoryGirl.define do
  factory :group do
    name { FFaker::Internet.domain_word }
  end
end
