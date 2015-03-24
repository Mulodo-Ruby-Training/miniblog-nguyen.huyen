# == Schema Information
#
# Table name: comments
#
#  id          :integer          not null, primary key
#  post_id     :integer          not null
#  user_id     :integer          not null
#  content     :string(255)      not null
#  created_at  :datetime         not null
#  modified_at :datetime         not null
#

class Comment < ActiveRecord::Base
  #------------------------------- begin associations ------------------------------#
  belongs_to :post
  belongs_to :user
  #------------------------------- begin named scopes ------------------------------#
  scope :search, lambda { | keyword = nil, page = nil, limit = nil, order = nil, user_id = nil, post_id = nil|
     comments = self
     # search by keyword
     if user_id
       comments = comments.where("comments.user_id = ?",user_id)
     end
     if post_id
       comments = comments.where("comments.post_id = ?",post_id)
     end
     if keyword && keyword.strip.length > 0
       comments =comments.where("MATCH (content) AGAINST (? IN NATURAL LANGUAGE MODE )", (keyword + '*'))
     end
     total = comments.count
     # select page, limit
     if page
       comments = comments.order(order => :desc).page(page).per(limit)
     end
     # get info
     hash = []
     comments.each do | comment |
       user = User.find_by(comment.user_id)
       post = Post.find_by(comment.post_id)
       info = {
           comment_id: comment.id,
           user_id: comment.user_id,
           post_id: post.id,
           username: user.username,
           comment_id: comment.id,
           post_title: post.title,
       }
       hash << info
     end
     hash = {:list => hash, :total => total}

     return hash
   }
end
