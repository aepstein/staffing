require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/schedules/new.html.erb" do
  include SchedulesHelper

  before(:each) do
    assigns[:schedule] = stub_model(Schedule,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new schedule form" do
    render

    response.should have_tag("form[action=?][method=post]", schedules_path) do
      with_tag("input#schedule_name[name=?]", "schedule[name]")
    end
  end
end
