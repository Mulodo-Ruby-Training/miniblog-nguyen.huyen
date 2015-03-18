Rails.application.routes.draw do
  scope :api, module: 'api', as: 'api' do
    post 'create_user'
    post 'login'
    post 'sign_out'
    post 'change_password'
    post 'update_user_info'
    get 'get_user_info'
    get 'search_user'
    post 'create_post'
    post 'change_status_of_post'
    post 'update_post'
    post 'delete_post'
    get 'search_post'
    get 'get_all_posts'
    get 'get_all_posts_for_user'
    post 'create_comment'
    post 'update_comment'
    post 'delete_comment'
  end
end
