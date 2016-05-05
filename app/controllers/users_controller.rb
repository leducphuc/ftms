class UsersController < ApplicationController
  load_and_authorize_resource

  def show
    @activities = PublicActivity::Activity.user_activities(@user.id).recent.limit(20).decorate
    @user_courses = @user.user_courses
    @inprogress_course = @user_courses.course_progress.last
    @finished_courses = @user_courses.course_finished

    add_breadcrumb @user.name
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      sign_in @user, bypass: true
      redirect_to @user, notice: flash_message("updated")
    else
      flash[:alert] = flash_message "not_updated"
      render :edit
    end
  end

  private
  def user_params
    params.require(:user).permit User::ATTRIBUTES_PARAMS
  end
end
