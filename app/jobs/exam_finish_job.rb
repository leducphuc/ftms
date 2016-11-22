class ExamFinishJob < ApplicationJob
  queue_as :urgent

  def perform exam
    exam.finish!
    point = ExamServices::CalculatePointService.new(exam).perform
    user_subject = exam.user_subject
    unless point < user_subject.subject.subject_detail_min_score_to_pass
      user_subject.update_status user_subject.user, "finish"
    end
  end
end
