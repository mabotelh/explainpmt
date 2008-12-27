module ApplicationHelper
  include AcceptancetestsHelper
  include DashboardsHelper
  include InitiativesHelper
  include IterationsHelper
  include MilestonesHelper
  include ProjectsHelper
  include ReleasesHelper
  include StoriesHelper
  include TasksHelper
  include UsersHelper
  include PagingHelper

  VERSION = 'dev trunk'

  def admin_content(&block)
    yield if is_admin?
  end

  def collection_content(collection, &block)
    yield collection if collection and collection.size > 0
  end

  def empty_collection_content(collection, &block)
    yield if collection.size == 0
  end

  def column_content_for(cols, column, &block)
    yield unless cols.include?(column)
  end

  def error_container(error)
    content_tag :div, error, :id => 'SystemError'
  end

  def is_admin?
    current_user && current_user.admin
  end

  def other_projects
    current_user.projects.select { |p| p != @project }
  end

  def long_date(date)
    date.strftime('%A %B %d %Y')
  end

  def short_date(date)
    date.strftime('%a %b %d, %y')
  end

  def relative_date(date)
    'about ' + time_ago_in_words(date) + ' ago'
  end

  def numeric_date(date)
    date.strftime('%m/%d/%Y')
  end
  
  def medium_date(date)
    date.strftime('%B %d, %Y')
  end

  def top_menu
    main_menu_links [
      (@project ? main_menu_link('Dashboard', project_dashboard_path(@project)) : main_menu_link('Overview', dashboards_path)),
      main_menu_link('Users', users_path),
      main_menu_link('Projects', projects_path),
    ]
  end

  def main_menu
    main_menu_links [
      main_menu_link('Dashboard', project_dashboard_path(@project)),
      main_menu_link('Releases', project_releases_path(@project)),
      main_menu_link('Iterations', project_iterations_path(@project)),
      main_menu_link('Backlog', project_stories_path(@project)),
      main_menu_link('Initiatives', project_initiatives_path(@project)),
      main_menu_link('Acceptance Tests', project_acceptancetests_path(@project)),
      main_menu_link('Milestones', project_milestones_path(@project)),
      main_menu_link('Team', team_project_path(@project)),
      main_menu_link('Stats', project_stats_path(@project))
    ] if @project
  end

  def main_menu_link(title, url)
    html_options = current_page?(url) ? { 'class' => 'current' } : {}
    link_to(title,url,html_options)
  end

  def main_menu_links(urls)
    content_tag(:ul, :id => "MainMenu") do
      urls.inject(""){|lis, url| lis << content_tag(:li, url)}
    end
  end

  def create_action_option(text, href, options={})
    options[:method] = :get unless options[:method]
    qParams = options.to_a.collect!{|k,v| "#{k}=#{v}"}.join("&")
    content_tag("option", text, :value => "#{href}?#{qParams}")
  end

  def in_place_collection_editor_field(object,method,container, tag_options={})
    tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
    tag_options = { :tag => "span",
      :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor",
      :class => "in_place_editor_field" }.merge!(tag_options)
    url = tag_options[:url] || url_for( :action => "set_#{object}_#{method}", :id => tag.object.id )
    logger.debug("url: " + url.to_s)
    collection = container.inject([]) do |options, element|
      options << "['#{escape_javascript(element.last.to_s)}','#{escape_javascript(element.first.to_s)}']"
    end
    function =  "new Ajax.InPlaceCollectionEditor("
    function << "'#{object}_#{method}_#{tag.object.id}_in_place_editor',"
    function << "'#{url}',"
    function << "{collection: [#{collection.join(',')}]});"
#    function << "{collection: [#{collection.join(',')}], id: '#{object}_#{method}'});"
    tag.to_content_tag(tag_options.delete(:tag), tag_options) + javascript_tag(function)
    #logger.debug("crap... " + object.attributes[method])
  end
end
