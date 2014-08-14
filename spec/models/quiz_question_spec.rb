require 'spec_helper'

describe QuizQuestion, :type => :model do

  let(:quiz_question) { build :quiz_question }

  it "should save with valid attributes" do
    quiz_question.save!
  end

  it "should not save without a quiz" do
    quiz_question.quiz = nil
    expect(quiz_question.save).to be false
  end

  it "should not save without a question" do
    quiz_question.question = nil
    expect(quiz_question.save).to be false
  end

  it "should not save with a duplicate question for the same quiz" do
    quiz_question.save!
    duplicate = build(:quiz_question, quiz: quiz_question.quiz,
      question: quiz_question.question)
    expect(duplicate.save).to be false
  end

  it "should not save without a position" do
    quiz_question.position = nil
    expect(quiz_question.save).to be false
    quiz_question.position = 0
    expect(quiz_question.save).to be false
  end

end

