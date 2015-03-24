module ApplicationHelper
  def render_success(object = nil, message = nil, response_type = 'json')
    hash = {}
    hash[:meta] = {:status => 200,
                   :message => message }
    hash[:data] = object
    if response_type == 'json'
      render json: JSON.pretty_generate(JSON.parse(hash.to_json))
    elsif response_type == 'html'
      render text: JSON.pretty_generate(JSON.parse(hash.to_json))
    end
  end
  def render_failed(reason_number, message, response_type = 'json')
    hash = {}
    hash[:meta] ={:status => reason_number,
                  :message => message }
    if response_type == 'json'
      render json:  JSON.pretty_generate(JSON.parse(hash.to_json))
    elsif response_type == 'html'
      render json:  JSON.pretty_generate(JSON.parse(hash.to_json))
    end
  end
end
