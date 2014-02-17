# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class CampaignsController < EntitiesController
  before_filter :get_data_for_sidebar, :only => :index

  # GET /campaigns
  #----------------------------------------------------------------------------
  def index
    @campaigns = get_campaigns(:page => params[:page], :per_page => params[:per_page])

    respond_with @campaigns do |format|
      format.xls { render :layout => 'header' }
      format.csv { render :csv => @campaigns }
    end
  end

  # GET /campaigns/1
  # AJAX /campaigns/1
  # XLS /campaigns/1
  # XLS /campaigns/1
  # CSV /campaigns/1
  # RSS /campaigns/1
  # ATOM /campaigns/1
  #----------------------------------------------------------------------------
  def show
    respond_with(@campaign) do |format|
      format.html do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@campaign)
      end

      format.js do
        @stage = Setting.unroll(:opportunity_stage)
        @comment = Comment.new
        @timeline = timeline(@campaign)
      end

      format.xls do
        @leads = @campaign.leads
        render '/leads/index', :layout => 'header'
      end

      format.csv do
        render :csv => @campaign.leads
      end

      format.rss do
        @items  = "leads"
        @assets = @campaign.leads
      end

      format.atom do
        @items  = "leads"
        @assets = @campaign.leads
      end
    end
  end

  # GET /campaigns/new
  # GET /campaigns/new.json
  # GET /campaigns/new.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def new
    @campaign.attributes = {:user => current_user, :access => Setting.default_access, :assigned_to => nil}

    if params[:related]
      model, id = params[:related].split('_')
      if related = model.classify.constantize.my.find_by_id(id)
        instance_variable_set("@#{model}", related)
      else
        respond_to_related_not_found(model) and return
      end
    end

    respond_with(@campaign)
  end

  # GET /campaigns/1/edit                                                  AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Campaign.my.find_by_id($1) || $1.to_i
    end

    respond_with(@campaign)
  end

  # POST /campaigns
  #----------------------------------------------------------------------------
  def create
    @comment_body = params[:comment_body]

    respond_with(@campaign) do |format|
      if @campaign.save
        @campaign.add_comment_by_user(@comment_body, current_user)
        @campaigns = get_campaigns
        get_data_for_sidebar
      end
    end
  end

  # PUT /campaigns/1
  #----------------------------------------------------------------------------
  def update
    respond_with(@campaign) do |format|
      # Must set access before user_ids, because user_ids= method depends on access value.
      @campaign.access = params[:campaign][:access] if params[:campaign][:access]
      get_data_for_sidebar if @campaign.update_attributes(params[:campaign]) and called_from_index_page?
    end
  end

  # DELETE /campaigns/1
  #----------------------------------------------------------------------------
  def destroy
    @campaign.destroy

    respond_with(@campaign) do |format|
      format.html { respond_to_destroy(:html) }
      format.js   { respond_to_destroy(:ajax) }
    end
  end

  # PUT /campaigns/1/attach
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :attach

  # PUT /campaigns/1/discard
  #----------------------------------------------------------------------------
  # Handled by EntitiesController :discard

  # POST /campaigns/auto_complete/query                                    AJAX
  #----------------------------------------------------------------------------
  # Handled by ApplicationController :auto_complete

  # POST /campaigns/redraw                                                 AJAX
  #----------------------------------------------------------------------------
  def redraw
    current_user.pref[:campaigns_per_page] = params[:per_page] if params[:per_page]
    current_user.pref[:campaigns_sort_by]  = Campaign::sort_by_map[params[:sort_by]] if params[:sort_by]
    @campaigns = get_campaigns(:page => 1, :per_page => params[:per_page])
    set_options # Refresh options

    respond_with(@campaigns) do |format|
      format.js { render :index }
    end
  end

  # POST /campaigns/filter                                                 AJAX
  #----------------------------------------------------------------------------
  def filter
    session[:campaigns_filter] = params[:status]
    @campaigns = get_campaigns(:page => 1, :per_page => params[:per_page])

    respond_with(@campaigns) do |format|
      format.js { render :index }
    end
  end

private

  #----------------------------------------------------------------------------
  alias :get_campaigns :get_list_of_records

  #----------------------------------------------------------------------------
  def respond_to_destroy(method)
    if method == :ajax
      get_data_for_sidebar
      @campaigns = get_campaigns
      if @campaigns.blank?
        @campaigns = get_campaigns(:page => current_page - 1) if current_page > 1
        render :index and return
      end
      # At this point render destroy.js
    else # :html request
      self.current_page = 1
      flash[:notice] = t(:msg_asset_deleted, @campaign.name)
      redirect_to campaigns_path
    end
  end

  #----------------------------------------------------------------------------
  def get_data_for_sidebar
    @campaign_status_total = { :all => Campaign.my.count, :other => 0 }
    Setting.campaign_status.each do |key|
      @campaign_status_total[key] = Campaign.my.where(:status => key.to_s).count
      @campaign_status_total[:other] -= @campaign_status_total[key]
    end
    @campaign_status_total[:other] += @campaign_status_total[:all]
  end
end