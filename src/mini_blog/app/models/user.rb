# == Schema Information
#
# Table name: users
#
#  id          :integer          not null, primary key
#  type        :string(20)       default("normal"), not null
#  username    :string(30)       not null
#  password    :string(30)       not null
#  created_at  :datetime         not null
#  modified_at :datetime         not null
#

class User < ActiveRecord::Base
  #------------------------------- begin associations ------------------------------#
  has_one :profile
  #------------------------------- begin validations -------------------------------#
  validates :username, uniqueness: true, presence: true
  validates_length_of :username, :minimum => 6, :maximum => 30, :allow_blank => true
  validates_length_of :password, :minimum => 6, :maximum => 30, :allow_blank => true
  #------------------------------- begin named scopes ------------------------------#
  #------------------------------- begin external libraries ------------------------#
  #------------------------------- begin callback ----------------------------------#
  #------------------------------- begin class methods -----------------------------#
  #------------------------------- begin instance methods --------------------------#

end
