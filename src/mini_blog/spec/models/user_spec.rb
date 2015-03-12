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

require 'rails_helper'

RSpec.describe User, :type => :model do
  describe User do
    it "has a valid factory" do
      FactoryGirl.create(:user).should be_valid
    end
    it "is invalid without username" do
      FactoryGirl.build(:user, username: nil).should_not be_valid
    end

  end
end
