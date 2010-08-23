class AdminController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter
  before_filter :require_privileged_user, :only => :index
  
  def index
    @pending_user_events = Event.pending_for_users
    @pending_comment_events = Event.pending_for_comments
    @watch_list = User.watch_list
    @banned_list  = User.banned_list
  end
end