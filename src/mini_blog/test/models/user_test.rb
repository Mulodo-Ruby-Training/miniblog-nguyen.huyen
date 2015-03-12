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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
