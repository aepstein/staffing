require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/quizzes/edit.html.erb" do
  include QuizzesHelper

  before(:each) do
    assigns[:quiz] = @quiz = stub_model(Quiz,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "renders the edit quiz form" do
    render

    response.should have_tag("form[action=#{quiz_path(@quiz)}][method=post]") do
      with_tag('input#quiz_name[name=?]', "quiz[name]")
    end
  end
end
