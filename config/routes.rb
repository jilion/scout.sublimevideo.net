require 'sidekiq/web'

ScoutSublimevideo::Application.routes.draw do

  devise_for :admins, path: '', path_names: { sign_in: 'login', sign_out: 'logout' }

  mount Sidekiq::Web => '/sidekiq'

  # Sample of named route:
  get 'new_sites/:day' => 'carousel#new_sites_day'
  get 'new_active_sites/:day' => 'carousel#new_active_sites_week'

  root to: redirect("/new_sites/#{I18n.l(Time.utc(2010, 9, 14), format: :Y_m_d)}")
end
