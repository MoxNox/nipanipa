class PicturesController < ApplicationController
  before_filter :load_user, only: [:index]
  before_filter :load_picture, only: [:edit, :update, :destroy]

  def new
    @picture = current_user.pictures.build
  end

  def create
#   if params[:picture][:avatar] == "1" and current_user.main_picture
#     main_picture = current_user.main_picture
#     main_picture.avatar = false
#     main_picture.save
#   end
    @picture = current_user.pictures.build(params[:picture])
    if @picture.save
      redirect_to user_pictures_path(current_user),
                  notice: t('pictures.create.success')
    else
      flash.now[:error] = t('pictures.create.error')
      render 'new'
    end
  end

  def index
    @page_id = :pictures
    @pictures = @user.pictures.where(avatar: false)
  end

  def edit

  end

  def update
    if @picture.update_attributes(params[:picture])
      redirect_to user_pictures_path(current_user),
                  notice: t('pictures.update.success')
    else
      flash.now[:error] = t('pictures.update.error')
      render 'edit'
    end
  end

  def destroy
    if @picture.destroy
      redirect_to user_pictures_path(current_user),
                  notice: t('pictures.destroy.success')
    end
  end

  private

    def load_user
      @user = User.find(params[:user_id])
    end

    def load_picture
      @picture = current_user.pictures.find(params[:id])
    end
end
