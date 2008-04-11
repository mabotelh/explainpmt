class ReleasesController < ApplicationController
  before_filter :find_release, :except => [:index, :create, :new]

  def index
    @releases = @project.releases
  end

  def new
    common_popup(project_releases_path(@project))
  end

  def edit
    common_popup(project_release_path(@project, @release))
  end

  def create
    @release = Release.new params[:release]
    @release.project = @project
    render :update do |page|
      if @release.save
        flash[:status] = "New Release \"#{@release.name}\" has been created."
        page.redirect_to project_releases_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@release.errors.full_messages[0]) %>"
      end
    end
  end

  def update
    render :update do |page|
      if @release.update_attributes(params[:release])
        flash[:status] = "Release \"#{@release.name}\" has been updated."
        page.redirect_to project_releases_path(@project)
      else
        page[:flash_notice].replace_html :inline => "<%= error_container(@release.errors.full_messages[0]) %>"
      end
    end
  end

  def destroy
    render :update do |page|
      @release.destroy
      flash[:status] = "#{@release.name} has been deleted."
      page.redirect_to project_releases_path(@project)
    end
  end

  protected

  def find_release
    @release = Release.find params[:id]
  end

  def common_popup(url)
    render :update do |page|
      page.call 'showPopup', render(:partial => 'release_form', :locals => {:url => url})
    end
  end
end
