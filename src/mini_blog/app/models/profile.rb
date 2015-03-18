# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  first_name  :string(60)       not null
#  last_name   :string(60)       not null
#  gender      :integer          default(1), not null
#  address     :string(250)
#  birth_day   :datetime
#  email       :string(60)       not null
#  phone       :string(20)       not null
#  created_at  :datetime         not null
#  modified_at :datetime         not null
#

class Profile < ActiveRecord::Base
  #------------------------------- begin associations ------------------------------#
  belongs_to :user
  has_many :image
  #------------------------------- begin validations -------------------------------#
  validates :email, presence: true, uniqueness: true, length: 8..50, format: { with: /\A[a-z0-9\.]+@([a-z]{1,10}\.){1,2}[a-z]{2,4}\z/i,message: "Invalid Email"}
  validates :first_name, presence: true, length: 6..250
  validates :last_name, presence: true, length: 6..250

end
