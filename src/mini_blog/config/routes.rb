Rails.application.routes.draw do

  scope :api, module: 'api', as: 'api' do
    post 'create_user'
    post 'login'
    post 'sign_out'
    post 'change_password'
    post 'update_user_info'
    get 'get_user_info'
    get 'search_user'
  end
end
