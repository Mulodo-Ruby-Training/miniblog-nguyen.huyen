# == Schema Information
#
# Table name: images
#
#  id           :integer          not null, primary key
#  subject_id   :integer          not null
#  subject_type :string(60)       not null
#  name         :string(100)      not null
#  url          :string(100)      not null
#  created_at   :datetime         not null
#  modified_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe Image, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
