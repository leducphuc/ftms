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

  class << self
    def import file
      spread_sheet = open_spreadsheet file
      question = Question.new
      (2..spread_sheet.last_row).each do |number|
        current_row = spread_sheet.row number
        content = current_row[1]
        if current_row.first == Question.name
          subject_id = current_row.last.to_i
          question = Question.create content: content, subject_id: subject_id
        else
          is_correct = current_row.last.to_i == 1 ? true : false
          Answer.create content: content, is_correct: is_correct, question_id: question.id
        end
      end
    end

    def open_spreadsheet file
      case File.extname file.original_filename
      when ".csv" then Roo::CSV.new file.path
      when ".xls" then Roo::Excel.new file.path
      when ".xlsx" then Roo::Excelx.new file.path
      else raise I18n.t "import_data.unknown"
      end
    end
  end

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
end
