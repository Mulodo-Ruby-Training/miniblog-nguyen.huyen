Rails.application.routes.draw do
  root :to => 'product#index'

    scope :api, module: 'api', as: 'api' do
      post 'api_product01'
      post 'api_product02'
      post 'api_product03'
      post 'api_product04'

  end
end
