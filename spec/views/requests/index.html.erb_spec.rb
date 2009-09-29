require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/index.html.erb" do
  include RequestsHelper

  before(:each) do
    assigns[:requests] = [
      stub_model(Request,
        :term => 1,
        :position => 1,
        :user => 1,
        :state => "value for state"
      ),
      stub_model(Request,
        :term => 1,
        :position => 1,
        :user => 1,
        :state => "value for state"
      )
    ]
  end

  it "renders a list of requests" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for state".to_s, 2)
  end
end
