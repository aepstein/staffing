require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/answers/edit.html.erb" do
  include AnswersHelper

  before(:each) do
    assigns[:answer] = @answer = stub_model(Answer,
      :new_record? => false,
      :question => 1,
      :request => 1,
      :content => "value for content"
    )
  end

  it "renders the edit answer form" do
    render

    response.should have_tag("form[action=#{answer_path(@answer)}][method=post]") do
      with_tag('input#answer_question[name=?]', "answer[question]")
      with_tag('input#answer_request[name=?]', "answer[request]")
      with_tag('textarea#answer_content[name=?]', "answer[content]")
    end
  end
end
