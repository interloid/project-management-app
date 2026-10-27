class CommentsController < ApplicationController
  before_action :set_commentable
  before_action :set_comment, only: [ :edit, :update, :destroy ]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to @commentable, notice: "Comment added successfully."
    else
      redirect_to @commentable, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      redirect_to @commentable, notice: "Comment updated successfully."
    else
      redirect_to @commentable, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    if @comment.destroy
      redirect_to @commentable, notice: "Comment deleted successfully."
    else
      redirect_to @commentable, alert: "You are not authorized to delete this comment."
    end
  end

  private

  def set_commentable
    project_id = params[:project_id]
    task_id = params[:task_id]

    @commentable =
      if project_id.present?
        Project.find(project_id)
      elsif task_id.present?
        Task.find(task_id)
      else
        raise ActionController::BadRequest, "Project or task ID is required."
      end

    authorize @commentable, :show?
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
    authorize @comment
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
