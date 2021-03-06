# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/leads/show" do
  include LeadsHelper

  before do
    login_and_assign
    assign(:lead, @lead = FactoryGirl.create(:lead, :id => 42))
    assign(:users, [ current_user ])
    assign(:comment, Comment.new)
    assign(:timeline, [ FactoryGirl.create(:comment, :commentable => @lead) ])
  end

  it "should render lead landing page" do
    render
    view.should render_template(:partial => "comments/_new")
    view.should render_template(:partial => "shared/_timeline")
    view.should render_template(:partial => "shared/_tasks")

    rendered.should have_tag("div[id=edit_lead]")
  end

end
