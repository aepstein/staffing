require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/show.html.erb" do
  include RequestsHelper
  before(:each) do
    assigns[:request] = @request = stub_model(Request,
      :term => 1,
      :position => 1,
      :user => 1,
      :state => "value for state"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ state/)
  end
end
