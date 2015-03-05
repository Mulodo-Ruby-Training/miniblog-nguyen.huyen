# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  user_id     :integer          not null
#  first_name  :string(60)       not null
#  last_name   :string(60)       not null
#  gender      :integer          default(1), not null
#  address     :string(250)      not null
#  birth_day   :datetime         not null
#  email       :string(60)       not null
#  phone       :string(20)       not null
#  created_at  :datetime         not null
#  modified_at :datetime         not null
#

class Profile < ActiveRecord::Base
  #------------------------------- begin associations ------------------------------#
  belongs_to :user
  #------------------------------- begin validations -------------------------------#
end
