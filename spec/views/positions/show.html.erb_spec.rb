require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/positions/show.html.erb" do
  include PositionsHelper
  before(:each) do
    assigns[:position] = @position = stub_model(Position,
      :authority => 1,
      :committee => 1,
      :quiz => 1,
      :schedule => 1,
      :slots => 1,
      :voting => false,
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/false/)
    response.should have_text(/value\ for\ name/)
  end
end
