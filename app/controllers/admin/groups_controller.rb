class Admin::GroupsController < AdminController
  before_filter :group, only: [:edit, :show, :update, :destroy, :project_update]

  def index
    @groups = Group.scoped
    @groups = @groups.search(params[:name]) if params[:name].present?
    @groups = @groups.page(params[:page]).per(20)
  end

  def show
    @projects = Project.scoped
    @projects = @projects.not_in_group(@group) if @group.projects.present?
    @projects = @projects.all
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(params[:group])
    @group.owner = current_user

    if @group.save
      redirect_to [:admin, @group], notice: 'Group was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    group_params = params[:group].dup
    owner_id =group_params.delete(:owner_id)

    if owner_id
      @group.owner = User.find(owner_id)
    end

    if @group.update_attributes(group_params)
      redirect_to [:admin, @group], notice: 'Group was successfully updated.'
    else
      render action: "edit"
    end
  end

  def project_update
    project_ids = params[:project_ids]
    Project.where(id: project_ids).update_all(group_id: @group.id)

    redirect_to :back, notice: 'Group was successfully updated.'
  end

  def remove_project
    @project = Project.find(params[:project_id])
    @project.group_id = nil
    @project.save

    redirect_to :back, notice: 'Group was successfully updated.'
  end

  def destroy
    @group.destroy

    redirect_to admin_groups_path, notice: 'Group was successfully deleted.'
  end

  private

  def group
    @group = Group.find_by_code(params[:id])
  end
end
