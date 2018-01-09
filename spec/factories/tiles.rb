FactoryGirl.define do
  factory :tile do
    title { FFaker::CheesyLingo.title }
    content { FFaker::CheesyLingo.paragraph }
  end

  trait :with_image do
    tile_type 'image'
    file { File.open("#{Rails.root}/app/assets/images/cropped-mox.jpg") }
  end
end
