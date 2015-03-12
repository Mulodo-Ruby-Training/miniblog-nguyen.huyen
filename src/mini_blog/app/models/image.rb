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

class Image < ActiveRecord::Base
end
