class AddForeignKeyToQuestions < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :questions, :subjects
  end
end
