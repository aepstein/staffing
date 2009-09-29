require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/schedules/index.html.erb" do
  include SchedulesHelper

  before(:each) do
    assigns[:schedules] = [
      stub_model(Schedule,
        :name => "value for name"
      ),
      stub_model(Schedule,
        :name => "value for name"
      )
    ]
  end

  it "renders a list of schedules" do
    render
    response.should have_tag("tr>td", "value for name".to_s, 2)
  end
end
