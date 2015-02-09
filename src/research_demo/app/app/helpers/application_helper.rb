module ApplicationHelper
  def render_success(object = nil, message = nil, response_type = 'json')
    hash = { status: 1 }
    hash[:data] = object
    hash[:message] = message unless message.nil?
    if response_type == 'json'
      render json: JSON.pretty_generate(JSON.parse(hash.to_json))
    elsif response_type == 'html'
      render text: JSON.pretty_generate(JSON.parse(hash.to_json))
    end
  end
  def render_failed(reason_number, message, response_type = 'json')
    hash = { status: reason_number, message: message }
    if response_type == 'json'
      render json: JSON.pretty_generate(JSON.parse(hash.to_json))
    elsif response_type == 'html'
      render text: JSON.pretty_generate(JSON.parse(hash.to_json))
    end
  end
end
