class TasksController < ApplicationController
  before_filter :find_task, :except => [:new, :create]

  def new
    @story = Story.find params[:story_id]
    common_popup(project_story_tasks_path(@project))
  end

  def edit
    @task.return_ids_for_aggregations
    common_popup(project_story_task_path(@project, @task.story, @task))
  end

  def create
    @task = Task.new params[:task]
    @task.story = Story.find(params[:story_id])
    modify_status_params
    render :update do |page|
      if @task.save
        flash[:status] = "New Task \"#{@task.name}\" has been created."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@task.errors.full_messages[0]) %>"
      end
    end
  end

  def update
    modify_status_params
    render :update do |page|
      if @task.update_attributes(params[:task])
        flash[:status] = "Task \"#{@task.name}\" has been updated."
        page.call 'location.reload'
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@story.errors.full_messages[0]) %>"
      end
    end
  end

  def destroy
    render :update do |page|
      @task.destroy
      flash[:status] = "Task \"#{@task.name}\" has been deleted."
      page.redirect_to request.referer
    end
  end

  def take_ownership
    @task.assign_to(current_user)
    redirect_to request.referer
  end

  def release_ownership
    @task.release_ownership
    redirect_to request.referer
  end

  def assign_ownership
    @users = @project.users
    render :update do |page|
      page.call 'showPopup', render(:partial => 'assign_owner_form')
    end
  end

  def assign
    @task.assign_to(User.find params[:owner][:id])
    redirect_to request.referer
  end

  protected

  def find_task
    @task = Task.find params[:id]
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'story_task_form', :locals => {:url => url})
    end
  end

  def modify_status_params
    if params[:task]
      if params[:task][:status]
        params[:task][:status] =
          Task::Status.new(params[:task][:status].to_i)
      end
    end
  end

end
