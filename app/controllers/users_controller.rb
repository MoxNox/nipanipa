class UsersController < ApplicationController
  before_filter :signed_in_user,     only: [:index, :edit, :update, :destroy]
  before_filter :same_user,          only: [:edit, :update]
  before_filter :not_signed_in_user, only: [:new, :create]
  before_filter :admin_user,         only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @received_feedbacks = @user.received_feedbacks.paginate(page: params[:page])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to NiPaNiPa!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    flash[:sucess] = "User destroyed"
    redirect_to users_url
  end

  private

    def not_signed_in_user
      redirect_to(root_path) unless !signed_in?
    end

    def same_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user.admin? && !current_user?(@user)
    end

end
