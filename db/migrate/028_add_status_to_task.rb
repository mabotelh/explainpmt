class AddStatusToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :status, :integer
    Task.find(:all).each do |t|
      s = t.complete ? Task::Status::Complete : Task::Status::New
      t.update_attribute :status, s
      say "t.complete: " + t.complete.to_s
      say "t.status: " + t.status.to_s
    end
    remove_column :tasks, :complete
  end

  def self.down
    add_column :tasks, :complete, :boolean, :default => false
    Task.find(:all).each do |t|
      t.update_attribute :complete, t.status == Task::Status::Complete
    end
    remove_column :tasks, :status
  end
end
