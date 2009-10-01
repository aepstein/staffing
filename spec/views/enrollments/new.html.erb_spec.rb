require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/enrollments/new.html.erb" do
  include EnrollmentsHelper

  before(:each) do
    assigns[:enrollment] = stub_model(Enrollment,
      :new_record? => true,
      :position => 1,
      :committee => 1,
      :title => "value for title",
      :votes => 1
    )
  end

  it "renders new enrollment form" do
    render

    response.should have_tag("form[action=?][method=post]", enrollments_path) do
      with_tag("input#enrollment_position[name=?]", "enrollment[position]")
      with_tag("input#enrollment_committee[name=?]", "enrollment[committee]")
      with_tag("input#enrollment_title[name=?]", "enrollment[title]")
      with_tag("input#enrollment_votes[name=?]", "enrollment[votes]")
    end
  end
end
