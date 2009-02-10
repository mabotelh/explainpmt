require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:current_user] = users(:first)
  end

  def test_create_new_task
    get :create, :project_id => projects(:first).id, :story_id => stories(:first).id, :task => {:name => 'Hello!', :status => 1}
    assert_response :success
    assert_rjs :call, 'location.reload'
  end
end
