class ApiController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
# ---------------------------
# @: Huyen
# d: 15/02/06
# f:To do : search data on table products
# method: Post
# ---------------------------
  def api_product01
    hash = {}
    limit = 20
    # check params
    if params[:type].nil?
      render_failed(100, t('common.error.missing_param', {obj: 'job_level_id'})) and return
    end
    page = params[:page].to_i > 0 ? params[:page].to_i.abs : 1
    hash = Product.search(params[:type],page,limit)
    render_success(hash)
  end
  def api_product02
    product = Product.new(name: params[:name],description: params[:description])
    product.save!
    render_success
  end
  def api_product03
    product = Product.find(params[:id])
    product.destroy!
    render_success
  end
  def api_product04
    product = Product.find(params[:id])
    product.name = params[:name]
    product.description = params[:description]
    product.save!
    render_success
  end
end