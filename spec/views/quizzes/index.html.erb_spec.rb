require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/quizzes/index.html.erb" do
  include QuizzesHelper

  before(:each) do
    assigns[:quizzes] = [
      stub_model(Quiz,
        :name => "value for name"
      ),
      stub_model(Quiz,
        :name => "value for name"
      )
    ]
  end

  it "renders a list of quizzes" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end
