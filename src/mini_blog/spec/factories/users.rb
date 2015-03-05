require 'faker'
FactoryGirl.define do
  factory :user do |f|
    f.username  "abcdefgh"
    f.password Faker::Internet.password
    f.modified_at Faker::Time.forward
  end

end