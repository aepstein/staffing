require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/answers/show.html.erb" do
  include AnswersHelper
  before(:each) do
    assigns[:answer] = @answer = stub_model(Answer,
      :question => 1,
      :request => 1,
      :content => "value for content"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ content/)
  end
end
