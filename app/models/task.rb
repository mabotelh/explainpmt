class Task < ActiveRecord::Base
  belongs_to :story
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :story_id
  Statuses = []

  composed_of :status, :mapping => %w(status order), :class_name => 'Task::Status'

  class Status < Story::RankedValue
    class << self
      def new(order)
        super(order, Statuses)
      end
    end

    Statuses << New = create(1, 'New')
    Statuses << InProgress = create(2, 'In Progress')
    Statuses << ToVerify = create(3, 'To Verify')
    Statuses << Complete = create(4, 'Complete')
  end

  def assign_to(new_owner)
    self.owner = new_owner
    save
  end

  def release_ownership
    self.owner = nil
    save
  end

  def after_initialize
    self.status = Status::New unless self.status
  end
  
  def return_ids_for_aggregations
    self.instance_eval <<-EOF
      def status
        read_attribute('status')
      end
    EOF
  end

end
