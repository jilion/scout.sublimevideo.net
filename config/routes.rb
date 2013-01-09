ScoutSublimevideo::Application.routes.draw do
  # Sample of named route:
  get  'new/:day' => 'carousel#new_sites_day', as: 'new_sites_day'
  get  'active/:day' => 'carousel#new_active_sites_week', as: 'new_active_sites_week'
  post 'take/:token' => 'carousel#take', as: 'take'

  get 'stats' => 'stats#index', as: 'stats'

  root to: redirect("/new/#{I18n.l(Time.now.yesterday.midnight, format: :Y_m_d)}")
end
