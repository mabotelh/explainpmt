module StoriesHelper
  def link_to_new_story
    link_to_remote('Create Story Card', :url => new_project_story_path(@project), :method => :get)
  end

  def link_to_show_cancelled
    link_to_unless_current 'Show Cancelled', cancelled_project_stories_path(@project)
  end

  def link_to_show_all
    link_to_unless_current 'Show All', all_project_stories_path(@project)
  end

  def link_to_new_iteration_story(iteration)
    link_to_remote('Create Story Card', :url => new_project_iteration_story_path(@project, iteration), :method => :get)
  end

  def link_to_new_stories
    link_to_remote('Bulk Create', :url => bulk_create_project_stories_path(@project), :method => :get)
  end

  def link_to_story_with_sc(story)
    link_to("SC#{story.scid}", project_story_path(@project, story)) + '(' + truncate(story.title, 30) + ')'
  end

  def link_to_story(story, options={})
    link_to(options[:value] || story.title, project_story_path(story.project, story))
  end

  def link_to_assign_story_ownership(story)
    link_to_remote('assign', :url => assign_ownership_project_story_path(@project, story), :method => :get)
  end

  def link_to_take_story_ownership(story)
    link_to('take', take_ownership_project_story_path(@project, story), :method => :put)
  end

  def link_to_release_story_ownership(story)
    link_to('release', release_ownership_project_story_path(@project, story), :method => :put)
  end

  def link_to_new_acceptance_for(story)
    link_to_remote('Add Acceptance', :url => new_project_story_acceptancetest_path(@project, story), :method => :get)
  end

  def link_to_export_stories
    link_to 'Export All Stories', export_project_stories_path(@project)
  end

  def link_to_export_tasks
    link_to 'Export All Tasks', export_tasks_project_stories_path(@project)
  end

  def story_select_list_for(stories)
    stories.inject(""){|options, story| options << "<option value='#{story.id}'>SC#{story.scid}  (#{truncate(story.title,30)})</option>"}
  end

  def link_to_edit_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => edit_project_story_path(@project, story), :method => :get)
  end

  def link_to_clone_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => clone_story_project_story_path(@project, story), :method => :put)
  end

  def link_to_delete_story(story, options={})
    link_to_remote(options[:value] || story.title, :url => project_story_path(@project, story), :method => :delete, :confirm => 'Are you sure you want to delete? All associated data will also be deleted. This action can not be undone.')
  end

  def link_to_audit_story(story, options={})
    link_to_remote(options[:value] || "View History", :url => audit_project_story_path(@project, story), :method => :get)
  end

  def link_to_move_up_story(story, options={})
    link_to_remote(options[:value] || "Move Up", :url => move_up_project_story_path(@project, story), :method => :put)
  end

  def link_to_move_down_story(story, options={})
    link_to_remote(options[:value] || "Move Down", :url => move_down_project_story_path(@project, story), :method => :put)
  end

  def option_to_edit_story(story)
    create_action_option("Edit", edit_project_story_path(@project, story))
  end

  def option_to_clone_story(story)
    create_action_option("Clone", clone_story_project_story_path(@project, story), :method => :put)
  end

  def option_to_move_story_up(story)
    create_action_option("Move Up", move_up_project_story_path(@project, story), :method => :put)
  end

  def option_to_move_story_down(story)
    create_action_option("Move Down", move_down_project_story_path(@project, story), :method => :put)
  end

  def option_to_edit_story_position(story)
    create_action_option("Insert At", edit_numeric_priority_project_story_path(@project, story))
  end

  def option_to_delete_story(story)
    create_action_option("Delete", project_story_path(@project, story), :method => :delete, :confirm => 'Are you sure you want to delete?\r\nAll associated data will also be deleted. This action can not be undone.')
  end

  def option_to_audit_story(story)
    create_action_option("View History", audit_project_story_path(@project, story))
  end

  def value_in_place_editor(story)
    in_place_collection_editor_field(
      :story,
      :value,
      Story::Values.collect{|x| [x.name,x.order]},
      {:url => set_value_project_story_path(story.project, story), :script => true})
  end

  def risk_in_place_editor(story)
    in_place_collection_editor_field(
      :story,
      :risk,
      Story::Risks.collect{|x| [x.name,x.order]},
      {:url => set_risk_project_story_path(story.project, story), :script => true})
  end

  def status_in_place_editor(story)
    in_place_collection_editor_field(
      :story,
      :status,
      Story::Statuses.collect{|x| [x.name,x.order]},
      {:url => set_status_project_story_path(story.project, story), :script => true})
  end

  def points_in_place_editor(story)
    rv = "<span id='story_points_ipe_#{story.id}'>#{story.points}</span>"
    rv + "<script type='text/javascript'>
//<![CDATA[
new Ajax.InPlaceEditorWithEmptyText('story_points_ipe_#{story.id}', '#{set_points_project_story_path(story.project, story)}', {size:2,emptyText:'Not Set'})
//]]>
</script>"
  end

  def customer_in_place_editor(story)
    rv = "<span id='story_customer_ipe_#{story.id}'>#{story.customer}</span>"
    rv + "<script type='text/javascript'>
//<![CDATA[
new Ajax.InPlaceEditorWithEmptyText('story_customer_ipe_#{story.id}', '#{set_customer_project_story_path(story.project, story)}', {emptyText:'Not Set'})
//]]>
</script>"
#    in_place_editor_field(
#      :story,
#      :customer,
#      {},
#      {:url => set_customer_project_story_path(story.project, story), :script => true}
#    )
  end

end
