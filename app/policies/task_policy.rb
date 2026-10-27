class TaskPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user.admin? || record.assignee_id == user.id || record.project.owner_id == user.id || record.project.members.include?(user)
  end

  def create?
    user.admin? || record.project.owner_id == user.id || record.project.members.include?(user)
  end

  def update?
    user.admin? || record.assignee_id == user.id || record.project.owner_id == user.id
  end

  def destroy?
    user.admin? || record.project.owner_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(assignee_id: user.id).or(scope.where(project_id: user.member_projects.select(:id)))
          .or(scope.where(project_id: user.projects.select(:id))).distinct
      end
    end
  end
end
