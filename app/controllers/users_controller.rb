# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def edit
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update_attributes(user_params)
      flash[:success] = 'Your profile was updated!'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :description, :subscribed)
  end
end
