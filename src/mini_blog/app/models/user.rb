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

require "bcrypt"
require 'digest/md5'
class User < ActiveRecord::Base
  include BCrypt

  #------------------------------- begin associations ------------------------------#
  has_one :profile
  #------------------------------- begin validations -------------------------------#
  validates :username, uniqueness: true, presence: true

  validates_length_of :username, :minimum => 6, :maximum => 30, :allow_blank => true
  validates_length_of :password, :minimum => 6, :allow_blank => true
  #------------------------------- begin instance methods --------------------------#
  def create_password(param_password)
    self.salt_password = BCrypt::Engine.generate_salt
    self.password = BCrypt::Engine.hash_secret(param_password,salt_password)
  end
  def check_password(param_password)
    password = BCrypt::Engine.hash_secret(param_password,self.salt_password)
    if self.password == password
      return true
    else
      return false
    end
  end
  def update_token
    str =  self.username + "@" + self.id.to_s + "@" + Time.now.to_s
    token = Digest::MD5.hexdigest(str)
    self.token = token
  end
  def build_profile
    profile = Profile.new(
      user_id: self.id,
      first_name: self.username,
      last_name: self.username,
      email: self.username + "@domain.com",
      phone: "username_phone",
      created_at: Time.now,
      modified_at: Time.now
    )
    profile.save!
  end
  def signed_in?
    !self.token.nil? && self.token == session[:token]
  end
  #------------------------------- begin named scopes ------------------------------#
  scope :search, lambda { | keyword = nil, page = nil, limit = nil, order = nil|
     users = User.joins("left join profiles on profiles.user_id = users.id")
     # search by keyword
     if keyword && keyword.strip.length > 0
       #keyword = keyword + "*"
       #users = users.where("username LIKE ?",keyword)
       users =users.where("MATCH(username) AGAINST (? IN BOOLEAN MODE) OR
       MATCH(first_name,last_name) AGAINST (? IN BOOLEAN MODE)", keyword , keyword)
       #users = User.find(:all, :conditions => ("match(first_name) against (? IN BOOLEAN MODE)",keyword))

     end
     total = users.count
     # select page, limit
     if page
       #users = users.order(id: :desc).page(page).per(limit)
     end
     # get info
     hash = []
     avatar = nil
     users.each do | user |
       image = Image.find_by(subject_type: "avatar", subject_id: profile.id)
       avatar = image.url unless image.nil?
       info = {
           user_id: keyword,
           username: user.username,
           user_type: user.user_type,
           first_name: user.first_name,
           last_name: user.last_name,
           avatar: avatar,
           created_at: user.created_at
       }
       hash << info
     end
     hash = {:list => hash, :total => total}

     return hash
   }
end
