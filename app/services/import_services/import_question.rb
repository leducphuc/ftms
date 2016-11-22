class ImportServices::ImportQuestion < ImportServices::ImportService
  require "roo"
  REQUIRED_ATTRIBUTES = ["subject", "question", "level", "is_correct"]

  def initialize args
    super(args)
  end


  def valid?
    File.exists?(@file_path) && correct_file_type? && data_type_valid?
  end

  private
  def perform
    spread_sheet = open_sheet
    header = spread_sheet.row(1)
    questions = []
    (2..spread_sheet.last_row).each do |index|
      row = Hash[[header, spread_sheet.row(index)].transpose]
      subject = Subject.find_by name: row["subject"]
      correct_answer = row["is_correct"]
      answer_hash = row.except(*REQUIRED_ATTRIBUTES)
      answers_attributes = Hash.new
      i = 0
      answer_hash.each do |key, answer|
        next unless answer
        is_correct = key == correct_answer
        answer_attributes  = {content: answer, is_correct: is_correct}
        answers_attributes[i] = answer_attributes
        i += 1
      end
      question = subject.questions.new content: row["question"], level: row["level"], answers_attributes: answers_attributes
      if question.valid?
        @logfile.write_success_log Question.name
        questions << question
      else
        write_fails_log Question.name
      end
    end
    Question.import questions
    true
  end

  def data_type_valid?
    attributes = REQUIRED_ATTRIBUTES.to_set
    spread_sheet = open_sheet
    header_set = spread_sheet.row(1).to_set
    attributes.subset? header_set
  end

  def open_sheet
    Roo::Spreadsheet.open @file_path
  end
end
