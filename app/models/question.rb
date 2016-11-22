class Question < ApplicationRecord
  acts_as_paranoid

  ATTRIBUTES_PARAMS = [:content, :subject_id, :level,
    answers_attributes: [:id, :content, :is_correct, :_destroy]]

  belongs_to :subject

  has_many :answers, dependent: :destroy
  has_many :results, dependent: :destroy
  has_many :exams, through: :results

  validates :content, presence: true

  scope :random, ->count, level{where(level: level).order("RAND()").limit(count)}

  accepts_nested_attributes_for :answers, allow_destroy: true,
    reject_if: lambda {|a| a[:content].blank?}

  enum level: [:easy, :normal, :hard]

  delegate :name, to: :subject, prefix: true, allow_nil: true

  private
  def check_answers
    if answers.blank?
      errors.add :question, I18n.t("error.wrong_answer")
      return
    end
    size_answer_correct = 0
    answers.each do |answer|
      size_answer_correct += 1 if answer.is_correct?
    end
    errors.add :question, I18n.t("error.wrong_answer") unless
      size_answer_correct == 1
  end
  # to do
  CSV_REJECT_ATTRIBUTES = ["category_id"]
end
