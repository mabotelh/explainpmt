require File.dirname(__FILE__) + '/../test_helper'
require 'milestones_controller'

# Re-raise errors caught by the controller.
class MilestonesController; def rescue_action(e) raise e end; end

class MilestonesControllerTest < ActionController::TestCase
  FULL_PAGES = [:index]
  POPUPS = [ :new,:create,:show,:edit,:update ]
  NO_RENDERS = [:delete]
  ALL_ACTIONS = FULL_PAGES + POPUPS + NO_RENDERS + [:milestones_calendar]

  fixtures ALL_FIXTURES

  def setup
    @project_one = Project.find 1
    @project_two = Project.find 2
    @past_milestone1 = Milestone.find 1
    @past_milestone2 = Milestone.find 2
    @recent_milestone1 = Milestone.find 3
    @recent_milestone2 = Milestone.find 4
    @future_milestone1 = Milestone.find 5
    @future_milestone2 = Milestone.find 6
    @future_milestone3 = Milestone.find 7
    @future_milestone4 = Milestone.find 8
    
    @controller = MilestonesController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    @request.session[:current_user] = User.find 2
  end

  def test_authentication_required
    @request.session[:current_user] = nil
    ALL_ACTIONS.each do |a|
      process a
      assert_redirected_to :controller => 'users', :action => 'login'
      assert session[:return_to]
    end
  end

  def test_no_project_id
    (FULL_PAGES + NO_RENDERS).each do |a|
      process a
      assert_redirected_to :controller => 'errors', :action => 'index'
      assert_equal "You attempted to access a view that requires a project to " +
                   "be selected",
                   flash[:error]
    end
    POPUPS.each do |a|
      process a
      assert_redirected_to :controller => 'errors', :action => 'index'
      assert_equal "You attempted to access a view that requires a project to " +
                   "be selected",
                   flash[:error]
    end
  end

  def test_new
    get :new, 'project_id' => @project_one.id
    assert_response :success
    assert_template '_milestone_form'
    assert_equal @project_one, assigns(:project)
  end

  def test_create
    before_count = Milestone.count
    post :create, 'project_id' => @project_one.id,
         'milestone' => { 'name' => 'Test Create', 'date' => '2005-12-31' }
    assert_response :success
    assert_rjs :redirect_to, project_milestones_path(@project_one.id)
    assert_equal before_count + 1, Milestone.count
  end

  def test_edit
    get :edit, 'id' => @future_milestone1.id,
        'project_id' => @future_milestone1.project.id
    assert_response :success
    assert_template '_milestone_form'
    assert_equal @future_milestone1, assigns(:milestone)
  end

  def test_update
    post :update, 'id' => @future_milestone1.id,
         'project_id' => @future_milestone1.project.id,
         'milestone' => { 'name' => 'Fooooo!' }
    assert_response :success
    assert_rjs :call, "location.reload"
    m = Milestone.find(@future_milestone1.id)
    assert_equal 'Fooooo!', m.name
    assert flash[:status]
  end

  def test_delete
    get :destroy, 'project_id' => @project_one.id, 'id' => @future_milestone1.id
    assert_rjs :redirect_to, project_milestones_path(1)
#    assert_redirected_to :controller => 'milestones', :action => 'index'
    assert flash[:status]
    assert_raise(ActiveRecord::RecordNotFound) {
      Milestone.find(@future_milestone1.id)
    }
  end

  def test_show
    get :show, :id => @future_milestone1.id,
        :project_id => @future_milestone1.project.id
    assert_response :success
    assert_template '_show'
    assert_equal @future_milestone1, assigns(:milestone)
  end

# TODO: The 2 following tests don't seem to be relevant anymore.
#  def test_milestones_calendar_all_projects
#    get :milestones_calendar
#    assert_response :success
#    assert_template '_milestones_calendar'
#    days = empty_milestones_days_array
#    days[0][:milestones] << @future_milestone1
#    days[12][:milestones] << @future_milestone3
#    days[13][:milestones] << @future_milestone4
#    assert_equal days, assigns(:days)
#    assert_equal 'Upcoming Milestones (all projects):',
#                 assigns(:calendar_title)
#    assert_tag :tag => "li", :content =>"Project One: Milestone Seven"
#    assert_tag :tag => "li", :content =>"Project Two: Milestone Eight"
#  end
#
#  def test_milestones_calendar_one_project
#    get :milestones_calendar, 'project_id' => 1
#    assert_response :success
#    assert_template '_milestones_calendar'
#    days = empty_milestones_days_array
#    days[0][:milestones] << @future_milestone1
#    days[12][:milestones] << @future_milestone3
#    assert_equal days, assigns(:days)
#    assert_equal 'Upcoming Milestones:', assigns(:calendar_title)
#    assert_no_tag :tag => "li", :content =>"Project One: Milestone Seven"
#    assert_tag :tag => "li", :content =>"Milestone Seven"
#  end
  
  private

  def empty_milestones_days_array
    days = []
    14.times do |i|
      current_day = Date.today + i
      days << {
        :date => current_day,
        :name => Date::DAYNAMES[current_day.wday],
        :milestones => []
      }
    end
    return days
  end
end


