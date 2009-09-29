require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/quizzes/new.html.erb" do
  include QuizzesHelper

  before(:each) do
    assigns[:quiz] = stub_model(Quiz,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new quiz form" do
    render

    response.should have_tag("form[action=?][method=post]", quizzes_path) do
      with_tag("input#quiz_name[name=?]", "quiz[name]")
    end
  end
end
