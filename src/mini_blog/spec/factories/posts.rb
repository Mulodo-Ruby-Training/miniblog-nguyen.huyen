# == Schema Information
#
# Table name: posts
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  title             :string(250)      not null
#  short_description :text             not null
#  content           :text(2147483647) not null
#  status            :integer          default(1), not null
#  created_at        :datetime         not null
#  modified_at       :datetime         not null
#

FactoryGirl.define do
  factory :post do |f|
    f.title "title"
    f.short_description "short description"
    f.content "content"
    f.user_id 1
    f.status 1
  end
  factory :params_post, :class => "Post" do |f|
    f.token "token"
    f.title "title"
    f.short_description "short description"
    f.content "content"
    f.user_id 1
  end

end
