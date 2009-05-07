class Admin::SmsOnRails::DraftsController < Admin::SmsOnRails::BaseController
  include SmsOnRails::CreationSupport
  
  # GET /admin/sms/drafts
  # GET /admin/sms/drafts.xml
  def index
    @drafts = SmsOnRails::Draft.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @drafts }
    end
  end


  # GET /admin/sms/drafts/new
  # GET /admin/sms/drafts/new.xml
  def new
    @draft = SmsOnRails::Draft.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @draft }
    end
  end

  # GET /admin/sms/drafts/1/edit
  def edit
    @draft = SmsOnRails::Draft.find(params[:id])
  end

  def create
    create_sms_draft
  end
  
  # PUT /admin/sms/drafts/1
  # PUT /admin/sms/drafts/1.xml
  def update
    @draft = SmsOnRails::Draft.find(params[:id])

    respond_to do |format|
      if @draft.update_attributes(params[:draft])
        flash[:notice] = 'Draft was successfully updated.'
        format.html { redirect_to(sms_draft_url(:id => @draft)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @draft.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/sms/drafts/1
  # DELETE /admin/sms/drafts/1.xml
  def destroy
    @draft = SmsOnRails::Draft.find(params[:id])
    @draft.destroy

    respond_to do |format|
      format.html { redirect_to(sms_drafts_url) }
      format.xml  { head :ok }
    end
  end

  protected

  
  # overwrite to use send_sms if created that or
  # new for all the params
  def render_send_sms_template
    render :action => ((params[:previous_action]||params[:action] == 'send_sms') ? :send_sms : :new)
  end


end
