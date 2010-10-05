require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  context "AdminController when NOT logged in" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should "be redirected to login" do
        assert_redirected_to CASClient::Frameworks::Rails::Filter.login_url(@controller)
      end
    end
  end
  
  context "AdminController when logged in and admin user" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      admin_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
  end
  
  context "AdminController when logged in and moderator user" do
    setup do
      @controller = AdminController.new
      @request = ActionController::TestRequest.new
      @response = ActionController::TestResponse.new
      @asset = Factory :asset
      build_focus_for @asset
      @event = Event.create(:user => Factory(:user), :target_user => @comment1.author, :title => "reported")
      @comment1.events << @event
      moderator_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should render_template :index
    end
    
    context "#ignore an event" do
      setup do
        post :ignore, { :id => @event.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "update event" do
        assert_equal "ignored", @event.reload.state
      end
    end
    
    context "#ban a user" do
      setup do
        post :ban, { :id => @event.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "update event" do
        assert_equal "actioned", @event.reload.state
        assert_equal @user, @event.moderator
      end
      
      should "ban user" do
        assert_equal "banned", @comment1.author.reload.state
      end
    end
    
    context "#redeem a user" do
      setup do
        @comment1.author.ban(@user)
        post :redeem, { :id => @event.target_user.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "update event" do
        assert_equal "actioned", @event.reload.state
        assert_equal @user, @event.moderator
      end
      
      should "redeem user" do
        assert_equal "active", @comment1.author.reload.state
      end
    end
    
    context "#watch an unwatched user" do
      setup do
        post :watch, { :id => @comment1.author.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "update event" do
        assert_equal "actioned", @event.reload.state
        assert_equal @user, @event.moderator
      end
      
      should "create event" do
        watch = Event.first(:target_user_id => @comment1.author.id, :title => /watched/)
        assert_equal "actioned", watch.state
        assert_equal @user, watch.moderator
      end
      
      should "watch user" do
        assert_equal "watched", @comment1.author.reload.state
      end
    end
    
    context "#watch an unwatched user" do
      setup do
        author = @comment1.author
        author.watch(@user)
        author.save
        post :watch, { :id => author.id, :format => :js }
      end
      
      should respond_with :success
      should respond_with_content_type(:js)
      
      should "create event" do
        watch = Event.first(:target_user_id => @comment1.author.id, :title => /watched/)
        assert_equal "actioned", watch.state
        assert_equal @user, watch.moderator
      end
      
      should "unwatch user" do
        assert_equal "active", @comment1.author.reload.state
      end
    end
  end
  
  context "AdminController when logged in and not admin user or moderator user" do
    setup do
      @controller = AdminController.new
      @request    = ActionController::TestRequest.new
      @response   = ActionController::TestResponse.new   
      standard_cas_login
    end
    
    context "#index" do
      setup do
        get :index
      end
      
      should respond_with :redirect
      
      should "be redirected to login" do
        assert_redirected_to root_url
      end
    end
  end
end
