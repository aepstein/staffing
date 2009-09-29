require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/terms/new.html.erb" do
  include TermsHelper

  before(:each) do
    assigns[:term] = stub_model(Term,
      :new_record? => true,
      :schedule => 1
    )
  end

  it "renders new term form" do
    render

    response.should have_tag("form[action=?][method=post]", terms_path) do
      with_tag("input#term_schedule[name=?]", "term[schedule]")
    end
  end
end
