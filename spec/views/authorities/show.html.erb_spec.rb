require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authorities/show.html.erb" do
  include AuthoritiesHelper
  before(:each) do
    assigns[:authority] = @authority = stub_model(Authority,
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
  end
end
