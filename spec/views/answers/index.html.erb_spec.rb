require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/answers/index.html.erb" do
  include AnswersHelper

  before(:each) do
    assigns[:answers] = [
      stub_model(Answer,
        :question => 1,
        :request => 1,
        :content => "value for content"
      ),
      stub_model(Answer,
        :question => 1,
        :request => 1,
        :content => "value for content"
      )
    ]
  end

  it "renders a list of answers" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for content".to_s, 2)
  end
end
