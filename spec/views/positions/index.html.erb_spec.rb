require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/positions/index.html.erb" do
  include PositionsHelper

  before(:each) do
    assigns[:positions] = [
      stub_model(Position,
        :authority => 1,
        :committee => 1,
        :quiz => 1,
        :schedule => 1,
        :slots => 1,
        :voting => false,
        :name => "value for name"
      ),
      stub_model(Position,
        :authority => 1,
        :committee => 1,
        :quiz => 1,
        :schedule => 1,
        :slots => 1,
        :voting => false,
        :name => "value for name"
      )
    ]
  end

  it "renders a list of positions" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", false.to_s, 2)
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end
