require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/qualifications/new.html.erb" do
  include QualificationsHelper

  before(:each) do
    assigns[:qualification] = stub_model(Qualification,
      :new_record? => true,
      :name => "value for name",
      :description => "value for description"
    )
  end

  it "renders new qualification form" do
    render

    response.should have_tag("form[action=?][method=post]", qualifications_path) do
      with_tag("input#qualification_name[name=?]", "qualification[name]")
      with_tag("textarea#qualification_description[name=?]", "qualification[description]")
    end
  end
end
