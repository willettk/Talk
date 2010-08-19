class CommentsController < ApplicationController
  def create
    @discussion = Discussion.find(params[:discussion_id])
    @discussion.comments.build(params[:comment])
    
    if @discussion.save
      flash[:notice] = t 'controllers.comments.flash_create'      
      redirect_to :controller => @discussion.focus_type.underscore.pluralize.to_sym, :action => :show, :id => @discussion.focus.zooniverse_id
    end
  end
end
