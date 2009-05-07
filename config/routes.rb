ActionController::Routing::Routes.draw do |map|

  #Resources for sms on rails admin routes
  #url: localhost:3000/admin/sms/drafts goes to the app/controllers/admin/sms_on_rails/draft_controller.rb

  map.resources :sms_drafts,         :new => {:send_sms => :any}, :as => 'admin/sms/drafts',         :controller => 'admin/sms_on_rails/drafts'  do |draft|
    draft.resources :outbounds,      :collection => {:deliver_sms => :any}, :controller => 'admin/sms_on_rails/outbounds'
  end

  map.resources :sms_drafts,         :collection => {:send_sms => :any}, :as => 'admin/sms/drafts',         :controller => 'admin/sms_on_rails/drafts'

  map.resources :sms_phone_numbers,  :as => 'admin/sms/phone_numbers',  :controller => 'admin/sms_on_rails/phone_numbers'
  map.resources :sms_phone_carriers, :as => 'admin/sms/phone_carriers', :controller => 'admin/sms_on_rails/phone_carriers'

  map.resources :sms, :as => 'sms', :controller => 'sms_on_rails', :only => [:create, :show, :new, :index], :singular => 'sms'

  map.sms_admin '/admin/sms', :controller => 'admin/sms_on_rails/base', :action => 'index'

end#end sms routeM
