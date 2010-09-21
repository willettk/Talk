class CollectionsController < ApplicationController
  before_filter CASClient::Frameworks::Rails::Filter, :only => [:new, :edit, :add]
  respond_to :js, :only => [:add, :remove]
  
  def show
    find_collection
    
    @discussion = @collection.conversation
    @mentions = Discussion.mentioning(@collection)
    @comment = Comment.new
    @comments = @collection.conversation.comments
    
    @tags = @collection.keywords
  end
  
  def new
    @collection = Collection.new
    @asset = Asset.find_by_zooniverse_id(params[:object_id]) if params[:object_id]
  end
  
  def edit
    find_collection
  end
  
  def create
    if params[:collection_kind][:id] == "Live Collection"
      @collection = LiveCollection.new(params[:collection])
      @collection.tags = params[:keyword].values
    elsif params[:collection_kind][:id] == "Collection"
      @collection = Collection.new(params[:collection])
    end
    
    @collection.user = current_zooniverse_user
    
    if @collection.save
      flash[:notice] = I18n.t 'controllers.collections.flash_create'
      redirect_to collection_path(@collection.zooniverse_id)
    else
      render :action => 'edit'
    end
  end
  
  def update
    find_collection
    
    if @collection.is_a?(LiveCollection)
      @collection.tags = params[:keyword].values
    end
    
    if @collection.update_attributes(params[:collection])
      flash[:notice] = I18n.t 'controllers.collections.flash_updated'
      redirect_to collection_path(@collection.zooniverse_id)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    find_collection
    
    if @collection.user == current_zooniverse_user
      @collection.destroy
      flash[:notice] = I18n.t 'controllers.collections.flash_destroyed'
    else
      flash[:alert] = I18n.t 'controllers.collections.not_yours'
    end
    
    redirect_to collections_path
  end
  
  def add
    find_collection
    @asset = Asset.find(params[:asset_id])
    
    unless current_zooniverse_user == @collection.user
      flash[:notice] = I18n.t 'controllers.collections.not_yours'
    end
    
    if @collection.asset_ids.include? @asset.id
      flash[:notice] = I18n.t 'controllers.collections.already_added'
    else
      @collection.asset_ids << @asset.id
      
      if @collection.save
        flash[:notice] = I18n.t('controllers.collections.added')
        @success = true
      end
    end
  end
  
  def remove
    find_collection
    @asset = Asset.find_by_zooniverse_id(params[:asset_id])
    @collection.asset_ids.delete_if { |id| id == @asset.id }
    @collection.save
  end
  
  private
  def find_collection
    if params[:id] =~ /^CMZS/
      @focus = @collection = Collection.find_by_zooniverse_id(params[:id])
    else
      @focus = @collection = LiveCollection.find_by_zooniverse_id(params[:id])
    end
  end
end
