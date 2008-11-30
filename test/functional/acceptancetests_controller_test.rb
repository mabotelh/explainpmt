require File.dirname(__FILE__) + '/../test_helper'
require 'acceptancetests_controller'

# Re-raise errors caught by the controller.
class AcceptancetestsController; def rescue_action(e) raise e end; end

class AcceptancetestsControllerTest < Test::Unit::TestCase
  fixtures ALL_FIXTURES
  
  def setup
    @controller = AcceptancetestsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
   
    @project_one = Project.find 1
    @at_one = Acceptancetest.find 1
    @at_two = Acceptancetest.find 2
    @story_one = Story.find 1
    @request.session[:current_user] = User.find 2
  end

  def test_index
    get :index, :project_id => @project_one.id
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:acceptancetests)
    assert_equal 2, assigns(:acceptancetests).size

  end
  
  def test_clone_acceptance_with_story
    get :clone_acceptance, :story_id => @at_one.story_id, :id => @at_one.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns( :acceptancetest )
    assert_equal @at_one.story, assigns( :acceptancetest ).story
    assert_equal @at_one, assigns(:acceptancetest)
    assert_rjs :call, "location.reload"
  end
  
  def test_clone_acceptance_without_story
    get :clone_acceptance, :id => @at_two.id, :project_id => @project_one.id
    assert_kind_of Acceptancetest, assigns(:acceptancetest)
    assert_equal @at_two, assigns(:acceptancetest)
  end
  
  def test_export
     get :export, :project_id => @project_one.id
     assert assigns(:project)
     assert_template 'export'
  end
  
  def test_new_acceptance_test_for_a_story
    get :new, :story_id => @story_one.id, :project_id => @project_one.id
    assert_template '_acceptancetest_form'
    #TODO: There should be a way to verify that the form submit will contain
    #      story_id as a parameter.
  end
  
#  TODO: I can't seem to figure out what this test is supposed to do by looking at
#  the code.
#  
#  def test_new_acceptance_test_for_story_with_existing_acceptance_in_session
#    @request.session[:object] = Acceptancetest.new
#    get :new_acceptance_for_story, :story_id => @story_one.id, :project_id => @project_one.id
#    assert_kind_of Acceptancetest, assigns(:object)
#    assert assigns(:object).new_record?
#  end
end
