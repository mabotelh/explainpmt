


require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  fixtures ALL_FIXTURES
  def setup
    @admin = User.find 1
    @user_one = User.find 2
    @user_two = User.find 3
    @project_one = Project.find 1

    @controller = UsersController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[ :current_user ] = @user_one

    @user_one.salt = 'hello_world'
    @user_one.set_password = "hello_world"
    @user_one.save

  end

  def test_authentication_required
    @request.session[ :current_user ] = nil
    actions = [ :index, :edit, :update, :delete ]
    actions.each do |a|
      process a
      assert_redirected_to :controller => 'users', :action => 'login'
      assert session[ :return_to ]
    end
  end

# TODO: Some change removed the admin requirement from the controller,
#       only managed thru the view.
#  def test_admin_required
#    @request.session[ :current_user ] = @user_one
#    actions = [ :edit, :update, :destroy ]
#    actions.each do |a|
#      process a, :id => 2
#      assert_redirected_to :controller => 'error', :action => 'index'
#      assert_equal "You must be logged in as an administrator to perform " +
#        "the requested action.", flash[ :error ]
#    end
#  end

# TODO: If not admin, edit is not shown in the view.
#  def test_admin_not_required_on_edit_if_id_is_session_user
#    get :edit, 'id' => @user_one.id
#    assert_response :success
#    post :update, 'id' => @user_one.id, 'user' => {}
#    user = User.find @user_one.id
#    assert !user.admin?
#    assert_response :success
#    assert_template 'layouts/refresh_parent_close_popup'
#  end

  def test_admin_cannot_remove_own_admin_privileges
    @request.session[ :current_user ] = @admin
    get :edit, 'id' => @admin.id, 'user' => { 'admin' => '0' }
    assert_response :success
    user = User.find @admin.id
    assert user.admin?
  end

  def test_index
    get :index
    assert_template 'index'
    users = assigns( :users )
    db = User.find( :all, :order => 'last_name ASC, first_name ASC' )
    assert_paginator(users, db)
  end

  def test_new
    @request.session[ :current_user ] = @admin
    get :new
    assert_response :success
    assert_template '_user_form'
  end

  def test_new_from_invalid
    @request.session[ :current_user ] = @admin
    get :create
    assigns(:user).last_name = 'Foo'
    assert_kind_of User, assigns( :user )
    assert assigns( :user ).new_record?
    assert_equal 'Foo', assigns( :user ).last_name
    assert_nil session[ :new_user ]
  end

  def test_new_with_project_id
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, :project_id => @project_one.id,
      'user' => { 'username' => 'test_create',
      'set_password' => 'test_create_password',
      'set_password_confirmation' => 'test_create_password',
      'email' => 'test_create@example.com', 'first_name' => 'Test',
      'last_name' => 'Create' }
    assert_response :success
    assert_rjs :call, 'location.reload'
    user = assigns( :user )
    assert_kind_of User, user
    assert @project_one.users.include?( user )
    assert_equal num_users + 1, User.count
  end

  def test_create
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => { 'username' => 'test_create',
      'set_password' => 'test_create_password',
      'set_password_confirmation' => 'test_create_password',
      'email' => 'test_create@example.com', 'first_name' => 'Test',
      'last_name' => 'Create' }
    assert_response :success
    assert_rjs :call, 'location.reload'
    assert_equal num_users + 1, User.count
  end

  def test_create_invalid
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => {}
    assert assigns(:user).new_record?
    assert_equal num_users, User.count
  end

  def test_create_with_project_id
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'project_id' => @project_one.id,
      'user' => { 'username' => 'test_create_with_project',
        'set_password' => 'test_create_password',
        'set_password_confirmation' => 'test_create_password',
        'email' => 'test_create@example.com', 'first_name' => 'Test',
        'last_name' => 'Create' }         
    assert_rjs :call, 'location.reload'
    assert_equal num_users + 1, User.count
    user = User.find :first,
      :conditions => [ 'username = ?', 'test_create_with_project' ]  
    assert @project_one.users.include?( user )
  end

  def test_create_invalid_with_project_id
    @request.session[ :current_user ] = @admin
    num_users = User.count
    post :create, 'user' => {}, 'project_id' => @project_one.id
    assert_kind_of User, assigns(:user)
    assert assigns(:user).new_record?
    assert_equal num_users, User.count
  end

  def test_edit
    @request.session[ :current_user ] = @admin
    get :edit, 'id' => @user_one.id
    assert_response :success
    assert_template '_user_form'
    assert_equal @user_one, assigns( :user )
  end

  def test_edit_from_invalid
    @request.session[ :current_user ] = @admin
    @user_one.username = nil
    @request.session[ :edit_user ] = @user_one
    get :edit, 'id' => @user_one.id
    assert_equal @user_one, assigns( :user )
  end

  def test_update
    @request.session[ :current_user ] = @admin
    post :update, 'id' => @user_one.id, 'user' => { 'last_name' => 'Foo' }
    assert_response :success
    assert_rjs :call, 'location.reload'
    assert_equal 'Foo', User.find( @user_one.id ).last_name
  end

  def test_update_invalid
    @request.session[ :current_user ] = @admin
    post :update, 'id' => @user_one.id, 'user' => { 'username' => '' }
    @user_one.username = ''
    assert_equal @user_one, assigns(:user)
  end

  def test_delete
    set_referrer({:controller => 'dashboard', :action => 'index'})
    @request.session[ :current_user ] = @admin
    get :destroy, :id => @user_one.id
    assert_raise( ActiveRecord::RecordNotFound ) do
      User.find @user_one.id
    end
  end
  
  def test_should_redirect_user_to_dashboard_after_successful_authentication
    @user_one.salt = 'hello_world'
    @user_one.set_password = "hello_world"
    @user_one.save
    post :authenticate, :username => @user_one.username,
      :password => "hello_world"
     assert_redirected_to :controller => 'dashboards', :action => 'index'
  end
  
  def test_should_redirect_user_to_specified_url_after_successful_authentication
    @request.session[ :return_to ] = '/foo/bar'
    post :authenticate, :username => @user_one.username,
      :password => "hello_world"
    assert_equal 'http://test.host/foo/bar', @response.redirect_url
    assert_nil session[ :return_to ]
  end
  
#  TODO: This doesn't seem to exist anymore in the code.
#  def test_should_render_current_user_as_xml_after_successful_authentication
#    @request.env[ 'HTTP_ACCEPT' ] = 'application/xml'
#    post :authenticate, :username => @admin.username,
#      :password => @admin.password
#    assert_response :success
#    assert_equal @admin.to_xml( :dasherize => false ), @response.body
#  end
  
  def test_should_set_current_user_in_session_after_successful_authentication
    post :authenticate, :username => @user_one.username,
      :password => "hello_world"
    assert_equal @user_one, session[ :current_user ]
  end
  
  def test_should_not_set_current_user_after_authentication_failure
    post :authenticate
    assert_nil session[ :current_user ]
  end
  
  def test_should_redirect_to_login_after_authentication_failure
    post :authenticate
    assert_redirected_to :controller => 'users', :action => 'login'
  end
  
  def test_should_set_flash_error_after_authentication_failure
    post :authenticate
    assert_equal 'You entered an invalid username and/or password.',
      flash[ :error ]
  end
  

#  TODO: users_controller doesn't seem to react to xml anymore.
#  def test_should_render_xml_error_template_after_authentication_failure
#    @request.env[ 'HTTP_ACCEPT' ] = 'application/xml'
#    post :authenticate
#    assert_template 'shared/error'
#    assert_tag :tag => 'message',
#      :content => 'You entered an invalid username and/or password.'
#  end
  
  def test_should_render_login_template
    @request.session[ :current_user ] = nil
    get :login
    assert_response :success
    assert_template 'login'
  end
  
  def test_should_remove_current_user_from_session_on_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_nil session[ :current_user ]
  end
  
  def test_should_redirect_to_login_after_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_redirected_to login_users_path
  end
  
  def test_should_set_flash_status_after_logout
    @request.session[ :current_user ] = @user_one
    get :logout
    assert_redirected_to login_users_path
  end


  def test_remove_user_from_project
    get :remove_from_project, 'project_id' => @project_one.id, 'id' => @user_one.id
    assert_redirected_to :controller => 'projects', :action => 'team',
                         :id => @project_one.id
    assert flash[ :status ]
    assert !@project_one.users( true ).include?( @user_one )
  end

end
