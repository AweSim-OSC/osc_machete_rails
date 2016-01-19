Rails.application.routes.draw do

  resources :simulations do
    member do
      put 'submit'
      put 'copy'
    end
  end

  mount OscMacheteRails::Engine => "/osc_machete_rails"
end
