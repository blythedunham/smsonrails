class Admin::SmsOnRails::PhoneCarriersController < Admin::SmsOnRails::BaseController
  # GET /admin/sms/phone_carriers
  # GET /admin/sms/phone_carriers.xml
  def index
    @phone_carriers = SmsOnRails::PhoneCarrier.all :group => :name

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phone_carriers }
    end
  end

  # GET /admin/sms/phone_carriers/1
  # GET /admin/sms/phone_carriers/1.xml
  def show
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phone_carrier }
    end
  end

  # GET /admin/sms/phone_carriers/new
  # GET /admin/sms/phone_carriers/new.xml
  def new
    @phone_carrier = SmsOnRails::PhoneCarrier.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phone_carrier }
    end
  end

  # GET /admin/sms/phone_carriers/1/edit
  def edit
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])
  end

  # POST /admin/sms/phone_carriers
  # POST /admin/sms/phone_carriers.xml
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

  # PUT /admin/sms/phone_carriers/1
  # PUT /admin/sms/phone_carriers/1.xml
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

  # DELETE /admin/sms/phone_carriers/1
  # DELETE /admin/sms/phone_carriers/1.xml
  def destroy
    @phone_carrier = SmsOnRails::PhoneCarrier.find(params[:id])
    @phone_carrier.destroy

    respond_to do |format|
      format.html { redirect_to(sms_phone_carriers_url) }
      format.xml  { head :ok }
    end
  end
end
