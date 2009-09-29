require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/questions/new.html.erb" do
  include QuestionsHelper

  before(:each) do
    assigns[:question] = stub_model(Question,
      :new_record? => true,
      :name => "value for name",
      :content => "value for content",
      :global => false
    )
  end

  it "renders new question form" do
    render

    response.should have_tag("form[action=?][method=post]", questions_path) do
      with_tag("input#question_name[name=?]", "question[name]")
      with_tag("input#question_content[name=?]", "question[content]")
      with_tag("input#question_global[name=?]", "question[global]")
    end
  end
end
