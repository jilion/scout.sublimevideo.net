require 'sidekiq/web'

ScoutSublimevideo::Application.routes.draw do

  devise_for :admins, path: '', path_names: { sign_in: 'login', sign_out: 'logout' }

  admin_logged_in = lambda { |request| request.env["warden"].authenticate? }
  constraints admin_logged_in do
    mount Sidekiq::Web => '/sidekiq'
  end

  # Sample of named route:
  get 'new/:day' => 'carousel#new_sites_day', as: 'new_sites_day'
  get 'active/:day' => 'carousel#new_active_sites_week', as: 'new_active_sites_week'

  get 'stats' => 'stats#index', as: 'stats'

  root to: redirect("/new/#{I18n.l(Time.now.utc.midnight, format: :Y_m_d)}")
end
