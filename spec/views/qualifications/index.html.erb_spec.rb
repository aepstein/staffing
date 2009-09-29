require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/qualifications/index.html.erb" do
  include QualificationsHelper

  before(:each) do
    assigns[:qualifications] = [
      stub_model(Qualification,
        :name => "value for name",
        :description => "value for description"
      ),
      stub_model(Qualification,
        :name => "value for name",
        :description => "value for description"
      )
    ]
  end

  it "renders a list of qualifications" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
    response.should have_tag("tr>td", "value for description".to_s, 2)
  end
end
