# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  user_type     :string(20)       default("normal"), not null
#  username      :string(30)       not null
#  salt_password :string(200)      not null
#  password      :string(200)      not null
#  token         :string(200)
#  created_at    :datetime         not null
#  modified_at   :datetime         not null
#

require 'faker'
require "bcrypt"
FactoryGirl.define do
  factory :user do |f|
    f.username  "username01"
    f.salt_password BCrypt::Engine.generate_salt
    f.password  Faker::Internet.password
    f.modified_at Faker::Time.forward
    f.token nil
  end
  factory :param_user, :class => "User"  do |f|
    f.username "username01"
    f.user_type "admin"
    f.password "123456"
    f.retype_password "123456"
  end
  factory :user_info, :class => "User"  do |f|
    f.user_id 1
    f.first_name "user_firstname"
    f.last_name "user_lastname"
    f.email "username@example.com"
    f.phone "12345678910"
    f.avatar "/image/avatar_username.jpg"
  end

end
