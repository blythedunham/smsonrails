class Admin::SmsOnRails::OutboundsController < ApplicationController

  helper SmsOnRails::SmsHelper
  # GET /sms_on_rails_outbounds
  # GET /sms_on_rails_outbounds.xml
  def index
    if params[:sms_draft_id]
      @draft = SmsOnRails::Draft.find( params[:sms_draft_id] )
      @outbounds = @draft.outbounds
    end

    @outbounds ||= SmsOnRails::Outbound.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @outbounds }
    end
  end

  # GET /sms_on_rails_outbounds/1
  # GET /sms_on_rails_outbounds/1.xml
  def show
    @outbound = SmsOnRails::Outbound.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @outbound }
    end
  end

  # GET /sms_on_rails_outbounds/new
  # GET /sms_on_rails_outbounds/new.xml
  def new
    @outbound = SmsOnRails::Outbound.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @outbound }
    end
  end

  # GET /sms_on_rails_outbounds/1/edit
  def edit
    @outbound = SmsOnRails::Outbound.find(params[:id])
  end

  # POST /sms_on_rails_outbounds
  # POST /sms_on_rails_outbounds.xml
  def create
    @outbound = SmsOnRails::Outbound.new(params[:outbound])

    respond_to do |format|
      if @outbound.save
        flash[:notice] = 'SmsOnRails::Outbound was successfully created.'
        format.html { redirect_to(sms_outbound_url(:id => @outbound))}
        format.xml  { render :xml => @outbound, :status => :created, :location => @outbound }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @outbound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sms_on_rails_outbounds/1
  # PUT /sms_on_rails_outbounds/1.xml
  def update
    @outbound = SmsOnRails::Outbound.find(params[:id])

    respond_to do |format|
      if @outbound.update_attributes(params[:outbound])
        logger.debug "VAL: #{@outbound.sms_service_provider_id}"
        flash[:notice] = 'SmsOnRails::Outbound was successfully updated.' + "VAL: #{@outbound.sms_service_provider_id}"
        format.html { redirect_to(sms_outbound_url(:id => @outbound)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @outbound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sms_on_rails_outbounds/1
  # DELETE /sms_on_rails_outbounds/1.xml
  def destroy
    @outbound = SmsOnRails::Outbound.find(params[:id])
    @outbound.destroy

    respond_to do |format|
      format.html { redirect_to(outbounds_url) }
      format.xml  { head :ok }
    end
  end
end
