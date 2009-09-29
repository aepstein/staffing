require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authorities/new.html.erb" do
  include AuthoritiesHelper

  before(:each) do
    assigns[:authority] = stub_model(Authority,
      :new_record? => true,
      :name => "value for name"
    )
  end

  it "renders new authority form" do
    render

    response.should have_tag("form[action=?][method=post]", authorities_path) do
      with_tag("input#authority_name[name=?]", "authority[name]")
    end
  end
end
