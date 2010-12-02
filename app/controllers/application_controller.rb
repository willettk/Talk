class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_or_create_zooniverse_user
  before_filter :check_for_banned_user, :except => :cas_logout
  
  def default_params(*args)
    hash = args.extract_options!
    
    hash.each_pair do |param, default|
      value = params[param] ? params[param] : default
      
      if default.is_a?(Integer)
        value = value.to_i
      elsif default.is_a?(Fixnum)
        value = value.to_i
      elsif default.is_a?(Float)
        value = value.to_f
      end
      
      instance_variable_set "@#{ param.to_s }", value
    end
  end
  
  def markdown(text)
    formatted = text.gsub(/#/m, '\#').gsub(/[\r\n]/, "\n\n")
    output = BlueCloth::new(formatted, :escape_html => true, :auto_links => true).to_html
    tags = ["h1","h2","h3","h4","h5","h6"]
    tags.each do |tag|
      output.gsub!(/<#{tag}\b[^>]*>(.*?)<\/#{tag}>/im, '\1')
    end
    
    return output
  end
  helper_method :markdown
  
  def get_featured_discussions
    @featured_list = Discussion.featured.all
  end
  
  helper_method :get_featured_discussions
  
  def new_discussion_url_for(focus)
      case focus.class.to_s
      when "Asset"
        new_object_discussion_path(focus.zooniverse_id)
      when "Board"
        new_board_discussion_path(focus.title)
      when "Collection", "LiveCollection"
        new_collection_discussion_path(focus.zooniverse_id)
      end
  end
  
  helper_method :new_discussion_url_for
  
  def discussion_url_for(*args)
    options = args.extract_options!
    options.delete(:page) if options[:page] == 1
    discussion = args.first
    focus = discussion.focus
    
    if !focus.is_a?(Board) && discussion.conversation?
      case focus.class.to_s
      when "Asset"
        object_path(focus.zooniverse_id, options)
      when "Collection", "LiveCollection"
        collection_path(focus.zooniverse_id, options)
      end
    else
      case focus.class.to_s
      when "Asset"
        object_discussion_path(focus.zooniverse_id, discussion.zooniverse_id, options)
      when "Board"
        query_string = options.any? ? "?#{ options.to_query }" : ""
        "/#{ discussion.focus.title.downcase }/discussions/#{ discussion.zooniverse_id }#{ query_string }"
      when "Collection", "LiveCollection"
        collection_discussion_path(focus.zooniverse_id, discussion.zooniverse_id, options)
      end
    end
  end
  
  def parent_url_for(discussion)
    focus = discussion.focus
    case focus.class.to_s
    when "Asset"
      object_path(focus.zooniverse_id)
    when "Board"
      "/#{focus.title.downcase}"
    when "Collection", "LiveCollection"
      collection_path(focus.zooniverse_id)
    end
  end
  
  helper_method :parent_url_for
  
  helper_method :discussion_url_for
  
  def require_privileged_user
    unless current_zooniverse_user && (current_zooniverse_user.moderator? || current_zooniverse_user.admin?)
      flash[:notice] = t 'controllers.application.not_authorised'
      redirect_to root_url
    end
  end
  
  def cas_logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end
  helper_method :cas_logout
  
  def cas_login
    "#{CASClient::Frameworks::Rails::Filter.client.login_url}?service=http%3A%2F%2F#{ request.host_with_port }#{ request.fullpath }"
  end
  helper_method :cas_login
  
  def flash_model_errors_on(doc)
    flash[:alert] = doc.errors.full_messages.join("\n") if doc.errors.respond_to?(:full_messages) && doc.errors.any?
  end
  
  helper_method :flash_model_errors_on
  
  protected
  
  def zooniverse_user
    session[:cas_user]
  end
  
  def zooniverse_user_id
    session[:cas_extra_attributes]['id']
  end
  
  def zooniverse_user_email
    session[:cas_extra_attributes]['email']
  end
  
  def current_zooniverse_user
    @current_zooniverse_user ||= (User.find_by_zooniverse_user_id(zooniverse_user_id) if zooniverse_user)
  end
  
  def check_or_create_zooniverse_user
    if zooniverse_user
      if user = User.find_by_zooniverse_user_id(zooniverse_user_id)
        user.update_attributes(:name => zooniverse_user, :email => zooniverse_user_email)
      else
        User.create(:zooniverse_user_id => zooniverse_user_id, :name => zooniverse_user, :email => zooniverse_user_email)
      end
    end
  end
  
  def check_for_banned_user
    if current_zooniverse_user
      if current_zooniverse_user.state == "banned"
        flash[:notice] = t 'controllers.home.banned'
        redirect_to root_url
      end
    end
  end
  
  helper_method :current_zooniverse_user
end
