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

require 'rails_helper'

RSpec.describe Post, :type => :model do

end
