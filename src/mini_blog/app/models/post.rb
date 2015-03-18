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
class Post < ActiveRecord::Base
  #------------------------------- begin named scopes ------------------------------#
  scope :search, lambda { | keyword = nil, page = nil, limit = nil, order = nil, user_id = nil|
     posts = self
     # search by keyword
     if user_id
       posts = posts.where("posts.user_id = ?",user_id)
     end
     if keyword && keyword.strip.length > 0
       posts =posts.where("MATCH (title, short_description, content) AGAINST (? IN NATURAL LANGUAGE MODE )", (keyword + '*'))
     end
     total = posts.count
     # select page, limit
     if page
       posts = posts.order(order => :desc).page(page).per(limit)
     end
     # get info
     hash = []
     posts.each do | post |
       user = User.find_by(post.user_id)
       info = {
           user_id: post.user_id,
           username: user.username,
           title: post.title,
           short_description: post.short_description
       }
       hash << info
     end
     hash = {:list => hash, :total => total}

     return hash
   }
end
