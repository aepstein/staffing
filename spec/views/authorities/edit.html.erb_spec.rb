require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authorities/edit.html.erb" do
  include AuthoritiesHelper

  before(:each) do
    assigns[:authority] = @authority = stub_model(Authority,
      :new_record? => false,
      :name => "value for name"
    )
  end

  it "renders the edit authority form" do
    render

    response.should have_tag("form[action=#{authority_path(@authority)}][method=post]") do
      with_tag('input#authority_name[name=?]', "authority[name]")
    end
  end
end
