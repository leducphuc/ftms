class ExamPolicy < ApplicationPolicy
  attr_reader :user, :controller, :action, :user_functions, :record

  def initialize user, args
    @user = user
    @controller_name = args[:controller]
    @action = args[:action]
    @user_functions = args[:user_functions]
    @record = args[:record]
  end

  def index?
    true
  end

  def show?
    @user = @record.trainee
  end

  def update?
    @user = @record.trainee
  end
end
