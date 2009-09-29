require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/answers/new.html.erb" do
  include AnswersHelper

  before(:each) do
    assigns[:answer] = stub_model(Answer,
      :new_record? => true,
      :question => 1,
      :request => 1,
      :content => "value for content"
    )
  end

  it "renders new answer form" do
    render

    response.should have_tag("form[action=?][method=post]", answers_path) do
      with_tag("input#answer_question[name=?]", "answer[question]")
      with_tag("input#answer_request[name=?]", "answer[request]")
      with_tag("textarea#answer_content[name=?]", "answer[content]")
    end
  end
end
