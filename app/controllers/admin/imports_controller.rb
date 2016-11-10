class Admin::ImportsController < ApplicationController
  def new
  end

  def create
    if Question.import params[:file]
      flash[:success] = t "import_data.success"
    else
      flash[:danger] = t "import_data.error"
    end
    redirect_to admin_questions_path
  end
end
