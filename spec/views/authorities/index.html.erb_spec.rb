require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authorities/index.html.erb" do
  include AuthoritiesHelper

  before(:each) do
    assigns[:authorities] = [
      stub_model(Authority,
        :name => "value for name"
      ),
      stub_model(Authority,
        :name => "value for name"
      )
    ]
  end

  it "renders a list of authorities" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end
