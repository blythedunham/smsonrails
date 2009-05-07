module SmsOnRails::CreationSupport 

  def send_sms
    setup_new_draft

    respond_to do |format|
      format.html { render_send_sms_template }
      format.xml  { render :xml => @draft }
    end
  end

  # GET /sms/new
  # GET /sms/new.xml
  def new; send_sms; end


  # GET /sms/1
  # GET /sms/1
  def show
    @draft = SmsOnRails::Draft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @draft }
    end
  end

  # GET /sms/1/edit
  def edit
    @draft = SmsOnRails::Draft.find(params[:id])
  end

  # POST /admin/sms/drafts
  # POST /admin/sms/drafts.xml
  def create_sms_draft

    # Create a draft, send it immediately if the send_immediately param is set
    # and do not throw fatal delivery exception errors
    @draft = SmsOnRails::Draft.create_sms(params[:draft], nil,
      :send_immediately => params[:send_immediately],
      :deliver => {:fatal_exception => nil })

    respond_to do |format|
      unless @draft.errors.any?
        flash[:notice] = 'Draft was successfully created and sent.'
        format.html { render_sms_creation_success }
        format.xml  { render :xml => @draft, :status => :created, :location => @draft }
      else
        unless @draft.outbounds.any?
          setup_new_draft
        else
          #evil hack as when :id is set, the nested attributes updates don't work
          @draft.outbounds.each{|o| o.phone_number.id = nil if o.phone_number}
        end
        sanitize_draft_errors(@draft)
        format.html { render_send_sms_template }
        format.xml  { render :xml => @draft.errors, :status => :unprocessable_entity }
      end
    end
  end

  def create; create_sms_draft; end


  protected

  def render_send_sms_template
    render :action => :send_sms
  end

  def render_sms_creation_success
    redirect_to(:overwrite_params => {:id => @draft, :action => :show } )
  end

  def setup_new_draft
    @phone_number  = SmsOnRails::PhoneNumber.new
    @outbound      = SmsOnRails::Outbound.new
    @draft         ||= SmsOnRails::Draft.new
    @outbound.phone_number = @phone_number
    @draft.outbounds      << @outbound
  end
  
  # Clean up the error messages on drafts a little
  def sanitize_draft_errors(draft)
    if draft.errors.any?
      errors = draft.errors.dup
      draft.errors.clear
      errors.each{|attr, message|
        if attr == 'outbounds_phone_number_phone_number_digits'
          draft.errors.add(:outbounds_phone_number, message)
        elsif !(attr =~ /^outbounds_phone_number/) && !(attr == 'outbounds' && message == 'is invalid')
          draft.errors.add(attr, message)
        end
      }
    end
  end


end
