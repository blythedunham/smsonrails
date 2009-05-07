class Admin::SmsOnRails::OutboundsController < Admin::SmsOnRails::BaseController
  # GET /admin/sms/outbounds
  # GET /admin/sms/outbounds.xml
  def index
    if params[:sms_draft_id]
      @draft = SmsOnRails::Draft.find( params[:sms_draft_id], :include => :outbounds )
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
    @outbound = SmsOnRails::Outbound.new(:sms_draft_id => params[:sms_draft_id])

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
    @draft = SmsOnRails::Draft.find(params[:sms_draft_id]) if params[:sms_draft_id]
    @outbound = SmsOnRails::Outbound.create_with_phone(params[:outbound], @draft)

    respond_to do |format|
      unless @outbound.errors.any?
        flash[:notice] = 'Outbound was successfully created.'
        format.html { redirect_to(sms_draft_outbound_path(@draft, @outbound))}
        format.xml  { render :xml => @outbound, :status => :created, :location => @outbound }
      else
        # evil hack as forms are rejected with an id value
        @outbound.phone_number.id = nil if @outbound.phone_number
        
        format.html { render :action => "new" }
        format.xml  { render :xml => @outbound.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/sms/outbounds/1
  # PUT /admin/sms/outbounds/1.xml
  def update
    @outbound = SmsOnRails::Outbound.find(params[:id])

    if params[:outbound]
      @outbound.update_attributes(params[:outbound])
    end

    if @outbound.errors.blank? && params[:send_immediately]
      deliver_sms('Outbound message was updated and sent.')
    end

    respond_to do |format|
      unless @outbound.errors.any?
        flash[:notice] = 'Outbound was successfully updated.'
        format.html { redirect_to(sms_draft_outbound_path(@outbound.draft, @outbound)) }
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
    @draft = @outbound.draft
    @outbound.destroy

    respond_to do |format|
      format.html { redirect_to(sms_draft_outbounds_url(@draft)) }
      format.xml  { head :ok }
    end
  end

  def deliver_sms(success_message = nil)
    @outbound ||= SmsOnRails::Outbound.find(params[:id])
    respond_to do |format|
      if @outbound.deliver(:fatal_exception => nil)
        flash[:notice] = success_message || 'Outbound SMS was successfully sent'
        format.html { redirect_to(sms_draft_outbound_path(@outbound)) }
        format.xml  { head :ok }
      else
        format.html { render :action => :edit }
        format.xml  { render :xml => @outbound.errors, :status => :unprocessable_entity }
      end
    end
  end
end
