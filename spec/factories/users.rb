FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.free_email }
    company_name 'active bridge'
    password 'q1w2e3r4'
    notificable true
    role 'user'
  end

  factory :admin, parent: :user do
    role 'admin'
  end
end
