class Admin::SmsOnRails::DraftsController < ApplicationController
  # GET /admin/sms_on_rails_drafts
  # GET /admin/sms_on_rails_drafts.xml
  def index
    @drafts = SmsOnRails::Draft.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @drafts }
    end
  end

  # GET /admin/sms_on_rails_drafts/1
  # GET /admin/sms_on_rails_drafts/1.xml
  def show
    @draft = SmsOnRails::Draft.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @draft }
    end
  end

  # GET /admin/sms_on_rails_drafts/new
  # GET /admin/sms_on_rails_drafts/new.xml
  def new
    @draft = SmsOnRails::Draft.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @draft }
    end
  end

  # GET /admin/sms_on_rails_drafts/1/edit
  def edit
    @draft = SmsOnRails::Draft.find(params[:id])
  end

  # POST /admin/sms_on_rails_drafts
  # POST /admin/sms_on_rails_drafts.xml
  def create
    @draft = SmsOnRails::Draft.new(params[:draft])

    respond_to do |format|
      if @draft.save
        flash[:notice] = 'Draft was successfully created.'
        format.html { redirect_to(sms_draft_url(:id => @draft)) }
        format.xml  { render :xml => @draft, :status => :created, :location => @draft }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @draft.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/sms_on_rails_drafts/1
  # PUT /admin/sms_on_rails_drafts/1.xml
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

  # DELETE /admin/sms_on_rails_drafts/1
  # DELETE /admin/sms_on_rails_drafts/1.xml
  def destroy
    @draft = SmsOnRails::Draft.find(params[:id])
    @draft.destroy

    respond_to do |format|
      format.html { redirect_to(drafts_url) }
      format.xml  { head :ok }
    end
  end
end
