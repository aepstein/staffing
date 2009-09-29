require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/schedules/edit.html.erb" do
  include SchedulesHelper

  before(:each) do
    assigns[:schedule] = @schedule = stub_model(Schedule,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "renders the edit schedule form" do
    render

    response.should have_tag("form[action=#{schedule_path(@schedule)}][method=post]") do
      with_tag('input#schedule_name[name=?]', "schedule[name]")
    end
  end
end
