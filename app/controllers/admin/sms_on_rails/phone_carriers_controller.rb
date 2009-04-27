ActionController::Routing::Routes.draw do |map|
  #Resources for sms on rails admin routes
  #url: localhost:3000/admin/sms/drafts goes to the app/controllers/admin/sms_on_rails/draft_controller.rb
  map.resources :sms_drafts,         :as => 'admin/sms/drafts',         :controller => 'admin/sms_on_rails/drafts'  do |draft|
    draft.resources :outbounds,      :controller => 'admin/sms_on_rails/outbounds'
  end

  map.resources :sms_phone_numbers,  :as => 'admin/sms/phone_numbers',  :controller => 'admin/sms_on_rails/phone_numbers'
  map.resources :sms_outbounds,      :as => 'admin/sms/outbounds',      :controller => 'admin/sms_on_rails/outbounds'
  map.resources :sms_phone_carriers, :as => 'admin/sms/phone_carriers', :controller => 'admin/sms_on_rails/phone_carriers'
end
class Admin::SmsOnRails::PhoneCarriersController < ApplicationController
  # GET /admin/sms_on_rails_phone_carriers
  # GET /admin/sms_on_rails_phone_carriers.xml
  def index
    @phone_carriers = SmsOnRails::PhoneCarrier.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phone_carriers }
    end
  end

  # GET /admin/sms_on_rails_phone_carriers/1
  # GET /admin/sms_on_rails_phone_carriers/1.xml
  def show
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phone_carrier }
    end
  end

  # GET /admin/sms_on_rails_phone_carriers/new
  # GET /admin/sms_on_rails_phone_carriers/new.xml
  def new
    @phone_carrier = SmsOnRails::PhoneCarrier.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phone_carrier }
    end
  end

  # GET /admin/sms_on_rails_phone_carriers/1/edit
  def edit
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])
  end

  # POST /admin/sms_on_rails_phone_carriers
  # POST /admin/sms_on_rails_phone_carriers.xml
  def create
    @phone_carrier = SmsOnRails::PhoneCarrier.new(params[:phone_carrier])

    respond_to do |format|
      if @phone_carrier.save
        flash[:notice] = 'PhoneCarrier was successfully created.'
        format.html { redirect_to(sms_phone_carrier_url(:id => @phone_carrier)) }
        format.xml  { render :xml => @phone_carrier, :status => :created, :location => @phone_carrier }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_carrier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/sms_on_rails_phone_carriers/1
  # PUT /admin/sms_on_rails_phone_carriers/1.xml
  def update
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])

    respond_to do |format|
      if @phone_carrier.update_attributes(params[:phone_carrier])
        flash[:notice] = 'PhoneCarrier was successfully updated.'
        format.html { redirect_to(sms_phone_carrier_url(:id => @phone_carrier)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_carrier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/sms_on_rails_phone_carriers/1
  # DELETE /admin/sms_on_rails_phone_carriers/1.xml
  def destroy
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])
    @phone_carrier.destroy

    respond_to do |format|
      format.html { redirect_to(phone_carriers_url) }
      format.xml  { head :ok }
    end
  end
end
