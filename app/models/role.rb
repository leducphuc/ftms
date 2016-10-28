class Role < ApplicationRecord
  acts_as_paranoid

  ATTRIBUTES_PARAMS = [permissions_attributes: [:id, :model_class, :action, :_destroy]]
  ATTRIBUTES_ROLE_PARAMS = [:name, :role_type]

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_funtions, dependent: :destroy
  has_many :funtions, through: :role_funtions

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  accepts_nested_attributes_for :permissions, allow_destroy: true

  scope :not_admin, ->{where.not name: "admin"}

  enum role_type: [:admin, :trainer, :trainee]
end
