require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/committees/edit.html.erb" do
  include CommitteesHelper

  before(:each) do
    assigns[:committee] = @committee = stub_model(Committee,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "renders the edit committee form" do
    render

    response.should have_tag("form[action=#{committee_path(@committee)}][method=post]") do
      with_tag('input#committee_name[name=?]', "committee[name]")
    end
  end
end
