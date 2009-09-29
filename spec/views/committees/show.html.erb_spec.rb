require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/committees/show.html.erb" do
  include CommitteesHelper
  before(:each) do
    assigns[:committee] = @committee = stub_model(Committee,
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
  end
end
