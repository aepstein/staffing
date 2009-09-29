require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/committees/index.html.erb" do
  include CommitteesHelper

  before(:each) do
    assigns[:committees] = [
      stub_model(Committee,
        :name => "value for name"
      ),
      stub_model(Committee,
        :name => "value for name"
      )
    ]
  end

  it "renders a list of committees" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end
