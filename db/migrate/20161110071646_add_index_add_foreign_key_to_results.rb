class AddIndexAddForeignKeyToResults < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :results, :questions

    add_foreign_key :results, :answers

    add_foreign_key :results, :exams
  end
end
