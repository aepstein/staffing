require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/questions/edit.html.erb" do
  include QuestionsHelper

  before(:each) do
    assigns[:question] = @question = stub_model(Question,
      :new_record? => false,
      :name => "value for name",
      :content => "value for content",
      :global => false
    )
  end

  it "renders the edit question form" do
    render

    response.should have_tag("form[action=#{question_path(@question)}][method=post]") do
      with_tag('input#question_name[name=?]', "question[name]")
      with_tag('input#question_content[name=?]', "question[content]")
      with_tag('input#question_global[name=?]', "question[global]")
    end
  end
end
