class ImportServices::ImportQuestion < ImportServices::ImportService
  REQUIRED_ATTRIBUTES = ["subject", "question", "level", "is_correct"]

  def initialize args
    super args
  end

  def valid?
    File.exists?(@file_path) && correct_file_type? && data_type_valid?
  end

  def perform
    spread_sheet = open_sheet
    header = spread_sheet.row(1)
    (2..spread_sheet.last_row).each do |index|
      row = Hash[[header, spread_sheet.row(index)].transpose]
      subject = Subject.find_by name: row["subject"].strip
      correct_answer = row["is_correct"]
      answer_hash = row.except *REQUIRED_ATTRIBUTES
      answers_attributes = Hash.new
      i = 0
      answer_hash.each do |key, answer|
        next unless answer
        is_correct = key == correct_answer
        answer_attributes = {content: answer.to_s.strip, is_correct: is_correct}
        answers_attributes[i] = answer_attributes
        i += 1
      end
      question_content = row["question"].to_s.strip
      question = subject.questions.new content: question_content,
        level: row["level"].to_s.strip, answers_attributes: answers_attributes
      if question.save
        @logfile.write_success_log "Question: #{question_content}"
      else
        write_fails_log Question.name
        @logfile.write_fails_log "Question #{question_content}"
      end
    end
  end

  private
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
