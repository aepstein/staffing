require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/terms/show.html.erb" do
  include TermsHelper
  before(:each) do
    assigns[:term] = @term = stub_model(Term,
      :schedule => 1
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/1/)
  end
end
