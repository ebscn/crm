# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'spec_helper'

describe SubscriptionMailer do

  describe "comment notification" do
    let(:user) { FactoryGirl.create(:user, :email => 'notify_me@example.com') }
    let(:commentable) { FactoryGirl.create(:opportunity, :id => 47, :name => 'Opportunity name') }
    let(:comment) { FactoryGirl.create(:comment, :commentable => commentable) }
    let(:mail) { SubscriptionMailer.comment_notification(user, comment) }

    before :each do
      Setting.email_comment_replies.stub(:[]).with(:address).and_return("email_comment_reply@example.com")
    end

    it "uses email defined in settings as the sender" do
      mail.from.should eql(["email_comment_reply@example.com"])
    end

    it "sets user 'notify_me@example.com' as recipient" do
      mail.to.should eq(["notify_me@example.com"])
    end

    it "sets the subject" do
      mail.subject.should eq("RE: [opportunity:47] Opportunity name")
    end

    it "includes link to opportunity in body" do
      mail.body.encoded.should match('http://www.example.com/opportunities/47')
    end

    it "should set default reply-to address if email doesn't exist" do
      Setting.email_comment_replies.stub(:[]).with(:address).and_return("")
      Setting.stub(:host).and_return("fatfreecrm.com")
      mail.from.should eql(["no-reply@fatfreecrm.com"])
    end

    it "should set default reply-to address if email and host don't exist" do
      Setting.email_comment_replies.stub(:[]).with(:address).and_return("")
      Setting.stub(:host).and_return("")
      mail.from.should eql(["no-reply@example.com"])
    end

  end
end
