class AddForeignKeyToExams < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :exams, :users
    add_foreign_key :exams, :user_subjects
  end
end
