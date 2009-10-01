require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/enrollments/show.html.erb" do
  include EnrollmentsHelper
  before(:each) do
    assigns[:enrollment] = @enrollment = stub_model(Enrollment,
      :position => 1,
      :committee => 1,
      :title => "value for title",
      :votes => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ title/)
    response.should have_text(/1/)
  end
end
