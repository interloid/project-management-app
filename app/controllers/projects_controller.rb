class ProjectsController < ApplicationController
  include AttachmentManagement
  before_action :set_project, only: %i[show edit update destroy members]

  def index
    @projects = policy_scope(Project).includes(:owner)
    project_ids = @projects.select(:id)
    @member_counts = ProjectMember.where(project_id: project_ids).group(:project_id).count
    @task_counts = Task.where(project_id: project_ids).group(:project_id).count
  end

  def show
    authorize @project
    @comments = @project.comments.includes(:user).order(created_at: :desc).to_a
  end

  def new
    @project = current_user.projects.build
    authorize @project
  end

  def create
    @project = current_user.projects.build(project_params)

    authorize @project

    if @project.save
      ProjectCreatedJob.perform_later(@project.id)
      redirect_to @project, notice: "Project created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project
    @project.assign_attributes(project_attributes)

    if @project.save
      update_attachments

      redirect_to @project, notice: "Project updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project

    if @project.destroy
      redirect_to projects_path, notice: "Project deleted successfully."
    else
      redirect_to @project, alert: "Project could not be deleted."
    end
  end

  def members
    authorize @project, :show?

    render json: @project.members.select(:id, :name)
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :start_date, :end_date, member_ids: [], attachments: [])
  end

  def project_attributes
    project_params.except(:attachments)
  end
end
