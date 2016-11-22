class Import < ImportService
  require "roo"
  REQUIRED_ATTRIBUTES = ["subject", "question", "level", "is_correct"]

  def initialize file_path, model, verify_attribute, data_type, logfile
    super(file_path, model, verify_attribute, data_type, logfile)
  end


  def valid?
    File.exists?(@file_path) && correct_file_type? && data_type_valid?
  end

  def save
    if valid?
      save_from_sheet
    end
  end

  private
  def save_from_sheet
    spread_sheet = open_sheet
    header = spread_sheet.row(1)
    (2..spread_sheet.last_row).each do |index|
      row = Hash[[header, spread_sheet.row(index)].transpose]
      subject = Subject.find_by name: row["subject"]
      question = subject.questions.find_or_create_by content: row["question"], level: row["level"]
      correct_answer = row["is_correct"]
      answer_hash = row.except(*REQUIRED_ATTRIBUTES)
      answer_hash.each do |key, answer|
        next unless answer
        is_correct = key == row["is_correct"]
        question.answers.find_or_create_by content: answer, is_correct: is_correct
      end
    end
    true
  end

  def data_type_valid?
    attributes = ["subject", "question", "level", "is_correct"].to_set
    spread_sheet = open_sheet
    header_set = spread_sheet.row(1).to_set
    attributes.subset? header_set
  end

  def open_sheet
    Roo::Spreadsheet.open @file_path
  end
end
