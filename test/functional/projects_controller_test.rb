require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  FULL_PAGES = [:index, :new, :edit]
  POPUPS = [:add_users,:update_users]
  NO_RENDERS = [:remove_user,:destroy, :create, :update]
  ALL_ACTIONS = FULL_PAGES + POPUPS + NO_RENDERS
  REQUIRED = [:destroy]
  fixtures ALL_FIXTURES
  
  def setup
    @admin = User.find 1
    @user_one = User.find 2
    @user_two = User.find 3
    @project_one = Project.find 1
    @project_two = Project.find 2
    @project_three = Project.find 3
    @controller = ProjectsController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[:current_user] = @admin
  end

  def test_authentication_required
    @request.session[:current_user] = nil
    ALL_ACTIONS.each do |a|
      process a
      assert_redirected_to :controller => 'users', :action => 'login'
      assert session[:return_to]
    end
  end

  # There doesn't seem to be any role checking anymore...
#  def test_admin_required
#    @request.session[:current_user] = @user_two
#    REQUIRED.each do |a|
#      process a, 'id' => @project_one.id
#      assert_redirected_to :controller => 'error', :action => 'index'
#      assert_equal "You must be logged in as an administrator to " +
#                   "perform the requested action.",
#                   flash[:error]
#    end
#  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    projects = assigns( :projects )
    db_projects = Project.find( :all, :order => 'name ASC' )
    projects.each{ |p|
      assert db_projects.include?(p)
    }
#    assert_equal Project.find( :all, :order => 'name ASC' ),
#      assigns( :projects ).projects
  end

  def test_new
    get :new
    assert_response :success
    assert_template '_project_form'
  end

  def test_create_no_membership
    num_before_create = Project.count
    mem_num_before_create = current_user.projects.size
    post :create, 'project' => { 'name' => 'Test Create',
                                 'description' => '' }
    assert_response :success
    assert_rjs :redirect_to, projects_path
    assert_equal num_before_create + 1, Project.count
    assert_equal mem_num_before_create, current_user.projects.size
  end

  def test_create_add_membership
    num_before_create = Project.count
    mem_num_before_create = current_user.projects.size
    post :create, 'add_me' => '1', 'project' => { 'name' => 'Test Create',
                                                  'description' => '' }
    assert_response :success
    assert_rjs :redirect_to, projects_path
    assert_equal num_before_create + 1, Project.count
    assert_equal mem_num_before_create + 1, current_user.projects.size
  end

  def test_add_users
    get :add_users, 'id' => @project_one.id
    assert_response :success
    assert_equal @project_one, assigns( :project )
    assert_template '_add_users'
    available = User.find( :all, 
                           :order => 'last_name ASC, first_name ASC' ) -
                            @project_one.users
    assert_equal available, assigns( :available_users )
  end

  def test_update_users
    post :update_users, 'id' => @project_one.id,
         'selected_users' => [ @user_one.id, @user_two.id ]                         
    assert_redirected_to team_project_path(@project_one.id)
    assert flash[ :status ]
    [ @user_one, @user_two ].each do |u|
      assert @project_one.users.include?(u)
    end
  end

  def test_delete
    get :destroy, 'id' => @project_one.id
    assert_rjs :redirect_to, projects_path
    assert flash[ :status ]
    assert_raise( ActiveRecord::RecordNotFound ) do
      Project.find @project_one.id
    end
  end

  def test_edit
    get :edit, 'id' => @project_one.id
    assert_response :success
    assert_template '_project_form'
    assert_equal @project_one, assigns( :project )
  end

  def test_update
    post :update, 'id' => @project_one.id, 'project' => { 'name' => 'Test' }
    assert_rjs :redirect_to, projects_path
    project = Project.find @project_one.id
    assert_equal 'Test', project.name
  end

  def test_my_projects_list
    @request.session[ :current_user ] = @user_one
    get :index
    assert_response :success
    assert_template 'index'
    assert assigns( :projects ).include?( @project_one )
    assert assigns( :projects ).include?( @project_two )
    assert !assigns( :projects ).include?( @project_three )
  end

  def test_team
    @request.session[ :current_user ] = @admin
    get :team, 'id' => @project_one.id
    assert_template 'team'
    assert_paginator (assigns( :users ), @project_one.users)
    assert_equal @project_one, assigns( :project )
  end

  private

  def current_user
    @request.session[ :current_user ]
  end
end
