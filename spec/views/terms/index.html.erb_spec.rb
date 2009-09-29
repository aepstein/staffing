require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/terms/index.html.erb" do
  include TermsHelper

  before(:each) do
    assigns[:terms] = [
      stub_model(Term,
        :schedule => 1
      ),
      stub_model(Term,
        :schedule => 1
      )
    ]
  end

  it "renders a list of terms" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
