# == Schema Information
#
# Table name: products
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  name        :string(60)       not null
#  description :text             not null
#

class Product < ActiveRecord::Base
  scope :search, lambda { | keyword = nil, page = nil, limit = nil|
     products = self

     # search by keyword
     if keyword && keyword.strip.length > 0
       tokens = keyword.gsub('、', ',').split(',').collect {|c| "%#{c.downcase}%"}
       arr_filter_columns = ['`products`.`name`','`products`.`description`']
       products = products.where(((["CONCAT_WS(' ', " + arr_filter_columns.join(', ') + ') LIKE ?']*tokens.size).join(' OR ')),*(tokens).collect{ |token| [token] }.flatten)
     end
     total = products.count
     # select page, limit
     if page
       products = products.order(id: :desc).page(page).per(limit)
     end
     # get info
     hash = []
     products.each do | product |
       info = {
           id: product.id,
           name: product.name,
           description: product.description
       }
       hash << info
     end
     hash = {:list => hash, :total => total}

     return hash
   }
end
