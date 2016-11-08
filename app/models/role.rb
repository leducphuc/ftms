class Role < ApplicationRecord
  acts_as_paranoid

  ATTRIBUTES_PARAMS = [functions_attributes: [:id, :model_class, :action, :_destroy]]
  ATTRIBUTES_ROLE_PARAMS = [:name, :role_type]

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_functions, dependent: :destroy
  has_many :functions, through: :role_functions

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  accepts_nested_attributes_for :functions, allow_destroy: true

  scope :not_admin, ->{where.not name: "admin"}

  enum role_type: [:admin, :trainer, :trainee]

  def role_functions
    self.functions.collect{|function| [function.model_class, function.action]}
  end

  def has_function? controller, action
    role_functions.include? [controller, action]
  end
end
