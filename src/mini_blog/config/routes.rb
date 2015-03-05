Rails.application.routes.draw do

  scope :api, module: 'api', as: 'api' do
    post 'create_user'


  end
end
