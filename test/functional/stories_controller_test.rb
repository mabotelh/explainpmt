require File.dirname(__FILE__) + '/../test_helper'
require 'stories_controller'
require 'application_helper'

# Re-raise errors caught by the controller.
class StoriesController; def rescue_action(e) raise e end; end

class StoriesControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  include Arts
  
  def setup
    @user_one = User.find 2
    @project_one = Project.find 1
    @project_two = Project.find 2
    @iteration_one = Iteration.find 1
    @iteration_two = Iteration.find 2
    @story_one = Story.find 1
    @story_two = Story.find 2
    @story_three = Story.find 3
    @story_six = Story.find 6

    @controller = StoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:current_user] = @user_one
  end

  def test_backlog
    get :index, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_equal [ @story_six ], assigns( :stories )
  end

  def test_backlog_show_cancelled
    get :cancelled, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_equal [  @story_three, ], assigns( :stories )
  end

  def test_backlog_no_iterations
    Iteration.destroy_all
    Project.delete_all("id != #{@project_one.id}")
    get :index, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_tag :tag => "div", :content => "Nowhere to move story cards to."
  end

  def test_show
    get :show, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_response :success
    assert_template 'show'
    assert_equal @story_one, assigns( :story )
  end

  def test_delete
    path = {:controller => 'stories', :action => 'index',
      :project_id => @project_one.id.to_s}
    set_referrer(path)
    get :destroy, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_rjs :redirect_to, path
    assert_raise( ActiveRecord::RecordNotFound ) { Story.find @story_one.id }
  end


  def test_new_single_empty_title
    get :create, :project_id => @project_one.id
    assert_response :success
    assert_select_rjs :chained_replace_html, "flash_notice", 'title.'
  end

  def test_new_single
    get :create, :project_id => @project_one.id, :story => {:title => 'Hello!'}
    assert_response :success
    assert_rjs :call, 'location.reload'
  end

  def test_create_many
    num = @project_one.stories.backlog.size
    post :create_many, :project_id => @project_one.id,
      :story => {:titles => "New Story One\nNew Story Two\nNew Story Three"}
    assert_response :success
    #assert_template 'layouts/refresh_parent_close_popup'
    assert_equal num + 3, @project_one.stories( true ).backlog.size
    assert_equal "New story cards created.", flash[:status]
  end
  
  def test_create_empty
    num = Story.count
    post :create_many, :project_id => @project_one.id, 'story' => { 'titles' => ''}
    assert_select_rjs :chained_replace_html, "flash_notice", 'Please enter at least one story card title.'
  end

  def test_edit
    get :edit, 'project_id' => @project_one.id, 'id' => @story_one.id
    assert_response :success
#    assert_template 'edit'
    assert_equal @story_one, assigns( :story )
  end

  def test_edit_from_invalid
    @story_one.title = nil
    @request.session[ :story ] = @story_one
    test_edit
  end

  def test_update
    post :update, 'project_id' => @project_one.id, 'id' => @story_one.id,
      'story' => { 'title' => 'Test Update', 'status' => 1 }
    assert flash[ :status ]
    assert_rjs :call, 'location.reload'
  end


  def test_take_ownership
    set_referrer(
      :controller => 'iterations',
      :action => 'show',
      :id => @iteration_one.id.to_s,
      :project_id => @project_one.id.to_s
    )
    
    get :take_ownership, 'id' => @story_one.id, 'project_id' => @project_one.id
    assert_redirected_to :controller => 'iterations', :action => 'show',
      :id => @iteration_one.id.to_s, :project_id => @project_one.id.to_s
    assert_equal @request.session[ :current_user ],
      Story.find( @story_one.id ).owner
    assert_equal @request.session[ :current_user ].stories,
      [@story_one]
  end

  def test_release_ownership
    path = { :controller => 'iterations', :action => 'show',
      :id => @iteration_one.id.to_s, :project_id => @project_one.id.to_s }
    set_referrer(path)
    @story_one.owner = @request.session[ :current_user ]
    @story_one.save

    get :release_ownership, 'id' => @story_one.id,
      'project_id' => @project_one.id
    assert_redirected_to path
    assert_nil Story.find( @story_one.id ).owner
    assert @request.session[ :current_user ].stories.empty?
  end

  def test_find_destination_invalid_destination_type
    assert_raise RuntimeError do
      @controller.parse_destination('n|2')
    end
  end

  def test_find_destination_invalid_format
    assert_raise RuntimeError do
      @controller.parse_destination('')
    end
  end

  def test_move_to_iteration
    path = { :controller => 'iterations', :action => 'show',
      :id => @iteration_one.id.to_s, :project_id => @project_one.id.to_s }
    set_referrer(path)

    # test moving to an iteration
    post :move, 'id' => 1, 'project_id' => 1,
      'selected_stories' => [ 4, 5 ], 'move_to' => 'i|2'
    assert_redirected_to path
    sc_one = Story.find 4
    assert_equal @iteration_two, sc_one.iteration
    sc_two = Story.find 5
    assert_equal @iteration_two, sc_two.iteration
    assert flash[ :status ]
  end

  def test_move_to_project
    path = { :controller => 'iterations', :action => 'show',
      :id => @iteration_one.id.to_s, :project_id => @project_one.id.to_s }
    set_referrer(path)

    # test moving to an iteration
    post :move, 'id' => 1, 'project_id' => 1,
      'selected_stories' => [ 4, 5 ], 'move_to' => 'p|2'
    assert_redirected_to path
    sc_one = Story.find 4
    assert_equal @project_two, sc_one.project
    sc_two = Story.find 5
    assert_equal @project_two, sc_two.project
    assert flash[ :status ]
  end

  def test_move_to_backlog
    path = { :controller => 'iterations', :action => 'show',
      :id => @iteration_one.id.to_s, :project_id => @project_one.id.to_s }
    set_referrer(path)

    # test moving to an iteration
    post :move, 'id' => 1, 'project_id' => 1,
      'selected_stories' => [ 4, 5 ], 'move_to' => 'i|0'
    assert_redirected_to path
    sc_one = Story.find 4
    assert_nil sc_one.iteration
    sc_two = Story.find 5
    assert_nil sc_two.iteration
    assert flash[ :status ]
  end
end
