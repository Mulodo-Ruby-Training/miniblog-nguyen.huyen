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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
