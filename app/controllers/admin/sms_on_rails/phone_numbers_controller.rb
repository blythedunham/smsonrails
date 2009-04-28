class Admin::SmsOnRails::PhoneNumbersController < Admin::SmsOnRails::BaseController

  helper SmsOnRails::SmsHelper

  # GET /admin/sms_on_rails_phone_numbers
  # GET /admin/sms_on_rails_phone_numbers.xml
  def index

    if params[:sms_outbound_id]
      @outbounds = SmsOnRails::Outbound.find( params[:sms_outbound_id] )
      @phone_numbers = [@outbounds.phone_number]
    end

 
    @phone_numbers ||= SmsOnRails::PhoneNumber.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phone_numbers }
    end
  end

  # GET /admin/sms_on_rails_phone_numbers/1
  # GET /admin/sms_on_rails_phone_numbers/1.xml
  def show

    if params[:sms_outbound_id]
      @outbounds = SmsOnRails::Outbound.find( params[:sms_outbound_id] )
      @phone_number = @outbounds.phone_number
    end

    @phone_number ||= SmsOnRails::PhoneNumber.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /admin/sms_on_rails_phone_numbers/new
  # GET /admin/sms_on_rails_phone_numbers/new.xml
  def new
    @phone_number = SmsOnRails::PhoneNumber.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phone_number }
    end
  end

  # GET /admin/sms_on_rails_phone_numbers/1/edit
  def edit
    @phone_number = SmsOnRails::PhoneNumber.find(params[:id])
  end

  # POST /admin/sms_on_rails_phone_numbers
  # POST /admin/sms_on_rails_phone_numbers.xml
  def create
    @phone_number = SmsOnRails::PhoneNumber.new(params[:phone_number])

    respond_to do |format|
      if @phone_number.save
        flash[:notice] = 'PhoneNumber was successfully created.'
        format.html { redirect_to(sms_phone_number_path(:id => @phone_number)) }
        format.xml  { render :xml => @phone_number, :status => :created, :location => @phone_number }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/sms_on_rails_phone_numbers/1
  # PUT /admin/sms_on_rails_phone_numbers/1.xml
  def update
    @phone_number = SmsOnRails::PhoneNumber.find(params[:id])

    respond_to do |format|
      if @phone_number.update_attributes(params[:phone_number])
        flash[:notice] = 'PhoneNumber was successfully updated.'
        format.html { redirect_to(sms_phone_number_path(:id => @phone_number)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phone_number.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/sms_on_rails_phone_numbers/1
  # DELETE /admin/sms_on_rails_phone_numbers/1.xml
  def destroy
    @phone_number = SmsOnRails::PhoneNumber.find(params[:id])
    @phone_number.destroy

    respond_to do |format|
      format.html { redirect_to(sms_phone_numbers_url) }
      format.xml  { head :ok }
    end
  end
end
