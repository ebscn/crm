# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
require 'features/acceptance_helper'

feature 'Accounts', %q{
  In order to increase customer satisfaction
  As a user
  I want to manage accounts
} do

  before(:each) do
   do_login_if_not_already(:first_name => 'Bill', :last_name => 'Murray')
  end

  scenario 'should view a list of accounts' do
    2.times { |i| FactoryGirl.create(:account, :name => "Account #{i}") }
    visit accounts_page
    page.should have_content('Account 0')
    page.should have_content('Account 1')
    page.should have_content('Create Account')
  end

  scenario 'should create a new account', :js => true do
    visit accounts_page
    page.should have_content('Create Account')
    click_link 'Create Account'
    page.should have_selector('#account_name', :visible => true)
    fill_in 'account_name', :with => 'My new account'
    click_link 'Contact Information'
    fill_in 'account_phone', :with => '+1 2345 6789'
    fill_in 'account_website', :with => 'http://www.example.com'
    click_link 'Comment'
    fill_in 'comment_body', :with => 'This account is very important'
    click_button 'Create Account'

    find('div#accounts').should have_content('My new account')
    find('div#accounts').click_link('My new account') # avoid recent items link
    page.should have_content('+1 2345 6789')
    page.should have_content('http://www.example.com')
    page.should have_content('This account is very important')

    click_link "Dashboard"
    page.should have_content("Bill Murray created account My new account")
    page.should have_content("Bill Murray created comment on My new account")
  end

  scenario "remembers the comment field when the creation was unsuccessful", :js => true do
    visit accounts_page
    page.should have_content('Create Account')
    click_link 'Create Account'

    click_link 'Contact Information'
    fill_in 'account_phone', :with => '+1 2345 6789'

    click_link 'Comment'
    fill_in 'comment_body', :with => 'This account is very important'
    click_button "Create Account"

    page.should have_field("account_phone", :with => '+1 2345 6789')
    page.should have_field("comment_body", :with => 'This account is very important')
  end

  scenario 'should view and edit an account', :js => true, :versioning => true do
    FactoryGirl.create(:account, :name => "A new account")
    visit accounts_page
    find('div#accounts').click_link('A new account')
    page.should have_content('A new account')
    click_link 'Edit'
    fill_in 'account_name', :with => 'A new account *editted*'
    click_button 'Save Account'
    page.should have_content('A new account *editted*')

    click_link "Dashboard"
    page.should have_content("Bill Murray updated account A new account *editted*")
  end

  scenario 'should delete an account', :js => true do
    FactoryGirl.create(:account, :name => "My new account")
    visit accounts_page
    find('div#accounts').click_link('My new account')
    click_link 'Delete?'
    page.should have_content('Are you sure you want to delete this account?')
    click_link 'Yes'
    page.should have_content('My new account has been deleted')
  end

  scenario 'should search for an account', :js => true do
    2.times { |i| FactoryGirl.create(:account, :name => "Account #{i}") }
    visit accounts_page
    find('#accounts').should have_content("Account 0")
    find('#accounts').should have_content("Account 1")
    fill_in 'query', :with => "Account 0"
    find('#accounts').should have_content("Account 0")
    find('#accounts').should_not have_content("Account 1")
    fill_in 'query', :with => "Account"
    find('#accounts').should have_content("Account 0")
    find('#accounts').should have_content("Account 1")
    fill_in 'query', :with => "Contact"
    find('#accounts').should_not have_content("Account 0")
    find('#accounts').should_not have_content("Account 1")
  end
end
