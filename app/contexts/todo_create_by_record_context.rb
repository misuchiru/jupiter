class TodoCreateByRecordContext < BaseContext
  before_perform :build_todo
  after_perform :assign_to_record
  after_perform :calculate_todo

  def initialize(record)
    @record = record
  end

  def perform
    run_callbacks :perform do
      unless @todo.save
        errors.add(:base, :data_create_fail, message: @todo.errors.full_messages.join("\n"))
        return false
      end
      @todo
    end
  end

  private

  def build_todo
    @todo = @record.user.todos.new(attributes_for_todo)
  end

  def attributes_for_todo
    { project_id: @record.project_id,
      desc: @record.note }
  end

  def assign_to_record
    @record.update_attribute :todo, @todo
  end

  def calculate_todo
    TodoCalculateContext.new(@todo).perform
  end
end
