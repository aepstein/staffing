require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/questions/index.html.erb" do
  include QuestionsHelper

  before(:each) do
    assigns[:questions] = [
      stub_model(Question,
        :name => "value for name",
        :content => "value for content",
        :global => false
      ),
      stub_model(Question,
        :name => "value for name",
        :content => "value for content",
        :global => false
      )
    ]
  end

  it "renders a list of questions" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for content".to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
  end
end
