class AddTasksCountToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :tasks_count, :integer
  end
end
