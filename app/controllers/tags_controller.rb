# == Schema Information
#
# Table name: tags
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  user_id            :integer
#  approved           :boolean          default(FALSE)
#

class TagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = Tag.for_user current_user
  end

  def show
  end

  def create
    @tag.user = current_user
    @tag.approved = true if current_user.role? :admin
    @tag.save

    render :show
  end

  protected

  def tag_params
    params.require(:tag).permit(:name, :image)
  end
end
