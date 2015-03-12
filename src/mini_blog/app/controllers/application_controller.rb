class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery with: :exception
  # Set a filter that is invoked on every request
  before_filter :_set_current_session

  protected
  def _set_current_session
    # Define an accessor. The session is always in the current controller
    # instance in @_request.session. So we need a way to access this in
    # our model
    accessor = instance_variable_get(:@_request)

    # This defines a method session in ActiveRecord::Base. If your model
    # inherits from another Base Class (when using MongoMapper or similar),
    # insert the class here.
    ActiveRecord::Base.send(:define_method, "session", proc {accessor.session})
  end
end
