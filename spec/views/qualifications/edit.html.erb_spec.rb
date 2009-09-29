require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/qualifications/edit.html.erb" do
  include QualificationsHelper

  before(:each) do
    assigns[:qualification] = @qualification = stub_model(Qualification,
      :new_record? => false,
      :name => "value for name",
      :description => "value for description"
    )
  end

  it "renders the edit qualification form" do
    render

    response.should have_tag("form[action=#{qualification_path(@qualification)}][method=post]") do
      with_tag('input#qualification_name[name=?]', "qualification[name]")
      with_tag('textarea#qualification_description[name=?]', "qualification[description]")
    end
  end
end
