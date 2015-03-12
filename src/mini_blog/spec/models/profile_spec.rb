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

require 'rails_helper'

RSpec.describe Profile, :type => :model do

end
