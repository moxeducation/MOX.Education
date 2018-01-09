class Admin::TagsController < Admin::AdminController
  load_and_authorize_resource

  def index
    @tags = @tags.page params[:page]
  end

  def show
    render :edit
  end

  def new
    render :edit
  end

  def edit
  end

  def create
    if @tag.save
      redirect_to admin_tags_path
    else
      render :edit
    end
  end

  def update
    if @tag.update_attributes tag_params
      redirect_to admin_tags_path
    else
      render :edit
    end
  end

  def destroy
    @tag.destroy
    redirect_to admin_tags_path
  end

  def approve
    @tag.approved = true
    @tag.save

    redirect_to :back
  end

  def disapprove
    @tag.approved = false
    @tag.save

    redirect_to :back
  end

  protected

  def tag_params
    params.require(:tag).permit(:name, :image, :user_id, :approved)
  end
end
