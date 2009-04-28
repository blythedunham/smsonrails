ActionController::Routing::Routes.draw do |map|

  #Resources for sms on rails admin routes
  #url: localhost:3000/admin/sms/drafts goes to the app/controllers/admin/sms_on_rails/draft_controller.rb
  map.resources :sms_drafts,         :new => {:send_sms => :any}, :as => 'admin/sms/drafts',         :controller => 'admin/sms_on_rails/drafts'  do |draft|
    draft.resources :outbounds,      :controller => 'admin/sms_on_rails/outbounds'
  end

  #map.resources :sms_drafts,         :collection => {:send_sms => :any}, :as => 'admin/sms/drafts',         :controller => 'admin/sms_on_rails/drafts'

  map.resources :sms_phone_numbers,  :as => 'admin/sms/phone_numbers',  :controller => 'admin/sms_on_rails/phone_numbers'
  map.resources :sms_outbounds,      :as => 'admin/sms/outbounds',      :controller => 'admin/sms_on_rails/outbounds'
  map.resources :sms_phone_carriers, :as => 'admin/sms/phone_carriers', :controller => 'admin/sms_on_rails/phone_carriers'

  map.resource :sms, :as => 'sms', :controller => 'sms_on_rails'
  
end#end sms routes
