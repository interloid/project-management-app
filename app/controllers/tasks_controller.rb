class TasksController < ApplicationController
  include TaskFilters
  include AttachmentManagement
  before_action :set_task, only: [ :show, :edit, :update, :destroy ]

  def index
    @tasks = policy_scope(Task).includes(:project, :assignee)
    @projects = policy_scope(Project).order(:name)
    @tasks = apply_task_filters(@tasks)
  end

  def show
    authorize @task
    @comments = @task.comments.includes(:user).order(created_at: :desc).to_a
  end

  def new
    @task = Task.new
    load_form_data
  end

  def create
    @task = Task.new(task_params)

    return render_form_with_errors(:new) if @task.invalid?

    authorize @task

    if @task.save
      TaskCreatedJob.perform_later(@task.id)
      redirect_to @task, notice: "Task created successfully."
    else
      render_form_with_errors(:new)
    end

  rescue ActiveRecord::RecordNotFound
    redirect_to tasks_path, alert: "You are not authorized to create a task for this project."
  end

  def edit
    authorize @task
    load_form_data
  end

  def update
    authorize @task
    @task.assign_attributes(task_attributes)

    if @task.save
      update_attachments

      redirect_to @task, notice: "Task updated successfully."
    else
      render_form_with_errors(:edit)
    end
  end

  def destroy
    authorize @task

    if @task.destroy
      redirect_to tasks_path, notice: "Task deleted successfully."
    else
      redirect_to task_path(@task), alert: "Task could not be deleted."
    end
  end

  private

  def set_task
    @task = Task.find_by(id: params[:id])
    redirect_to tasks_path, alert: "Task not found." unless @task
  end

  def render_form_with_errors(template)
    load_form_data
    render template, status: :unprocessable_entity
  end

  def load_form_data
    @projects = policy_scope(Project)
    @assignees = @task.project&.members || User.none
  end

  def task_params
    params.require(:task).permit(:title, :description, :priority, :status, :start_date, :end_date, :project_id, :assignee_id, attachments: [])
  end

  def task_attributes
    task_params.except(:attachments)
  end
end
