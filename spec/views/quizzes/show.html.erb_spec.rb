require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/quizzes/show.html.erb" do
  include QuizzesHelper
  before(:each) do
    assigns[:quiz] = @quiz = stub_model(Quiz,
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
  end
end
