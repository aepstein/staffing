require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/terms/edit.html.erb" do
  include TermsHelper

  before(:each) do
    assigns[:term] = @term = stub_model(Term,
      :new_record? => false,
      :schedule => 1
    )
  end

  it "renders the edit term form" do
    render

    response.should have_tag("form[action=#{term_path(@term)}][method=post]") do
      with_tag('input#term_schedule[name=?]', "term[schedule]")
    end
  end
end
