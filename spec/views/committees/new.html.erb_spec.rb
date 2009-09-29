require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/committees/new.html.erb" do
  include CommitteesHelper

  before(:each) do
    assigns[:committee] = stub_model(Committee,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new committee form" do
    render

    response.should have_tag("form[action=?][method=post]", committees_path) do
      with_tag("input#committee_name[name=?]", "committee[name]")
    end
  end
end
