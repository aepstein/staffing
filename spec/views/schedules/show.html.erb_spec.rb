require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/schedules/show.html.erb" do
  include SchedulesHelper
  before(:each) do
    assigns[:schedule] = @schedule = stub_model(Schedule,
      :name => "value for name"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ name/)
  end
end
