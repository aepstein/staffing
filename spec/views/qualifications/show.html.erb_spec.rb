require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/qualifications/show.html.erb" do
  include QualificationsHelper
  before(:each) do
    assigns[:qualification] = @qualification = stub_model(Qualification,
      :name => "value for name",
      :description => "value for description"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
    response.should have_text(/value\ for\ description/)
  end
end
