class Admin::SmsOnRails::OutboundsController < Admin::SmsOnRails::BaseController
  # GET /admin/sms/outbounds
  # GET /admin/sms/outbounds.xml
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

  # GET /admin/sms/outbounds/1
  # GET /admin/sms/outbounds/1.xml
  def show
    @outbound = SmsOnRails::Outbound.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @outbound }
    end
  end

  # GET /admin/sms/outbounds/new
  # GET /admin/sms/outbounds/new.xml
  def new
    @outbound = SmsOnRails::Outbound.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @outbound }
    end
  end

  # GET /admin/sms/outbounds/1/edit
  def edit
    @outbound = SmsOnRails::Outbound.find(params[:id])
  end

  # POST /admin/sms/outbounds
  # POST /admin/sms/outbounds.xml
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

  # PUT /admin/sms/outbounds/1
  # PUT /admin/sms/outbounds/1.xml
  def update
    @outbound = SmsOnRails::Outbound.find(params[:id])

    respond_to do |format|
      if @outbound.update_attributes(params[:outbound])
        flash[:notice] = 'SmsOnRails::Outbound was successfully updated.' + "VAL: #{@outbound.sms_service_provider_id}"
        format.html { redirect_to(sms_outbound_url(:id => @outbound)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @outbound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/sms/outbounds/1
  # DELETE /admin/sms/outbounds/1.xml
  def destroy
    @outbound = SmsOnRails::Outbound.find(params[:id])
    @outbound.destroy

    respond_to do |format|
      format.html { redirect_to(outbounds_url) }
      format.xml  { head :ok }
    end
  end
end
