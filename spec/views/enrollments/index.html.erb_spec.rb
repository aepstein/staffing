require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/enrollments/index.html.erb" do
  include EnrollmentsHelper

  before(:each) do
    assigns[:enrollments] = [
      stub_model(Enrollment,
        :position => 1,
        :committee => 1,
        :title => "value for title",
        :votes => 1
      ),
      stub_model(Enrollment,
        :position => 1,
        :committee => 1,
        :title => "value for title",
        :votes => 1
      )
    ]
  end

  it "renders a list of enrollments" do
    render
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for title".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
  end
end
