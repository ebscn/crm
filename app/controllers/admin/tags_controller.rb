# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class Admin::TagsController < Admin::ApplicationController
  before_filter "set_current_tab('admin/tags')", :only => [ :index, :show ]

  load_resource

  # GET /admin/tags
  # GET /admin/tags.xml                                                   HTML
  #----------------------------------------------------------------------------
  def index
    @tags = Tag.all
    respond_with(@tags)
  end

  # GET /admin/tags/new
  # GET /admin/tags/new.xml                                               AJAX
  #----------------------------------------------------------------------------
  def new
    respond_with(@tag)
  end

  # GET /admin/tags/1/edit                                                AJAX
  #----------------------------------------------------------------------------
  def edit
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Tag.find_by_id($1) || $1.to_i
    end
  end

  # POST /admin/tags
  # POST /admin/tags.xml                                                  AJAX
  #----------------------------------------------------------------------------
  def create
    @tag.update_attributes(params[:tag])

    respond_with(@tag)
  end

  # PUT /admin/tags/1
  # PUT /admin/tags/1.xml                                                 AJAX
  #----------------------------------------------------------------------------
  def update
    @tag.update_attributes(params[:tag])

    respond_with(@tag)
  end

  # DELETE /admin/tags/1
  # DELETE /admin/tags/1.xml                                              AJAX
  #----------------------------------------------------------------------------
  def destroy
    @tag.destroy

    respond_with(@tag)
  end

  # GET /admin/tags/1/confirm                                             AJAX
  #----------------------------------------------------------------------------
  def confirm
  end
end
