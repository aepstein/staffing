require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/new.html.erb" do
  include RequestsHelper

  before(:each) do
    assigns[:request] = stub_model(Request,
      :new_record? => true,
      :term => 1,
      :position => 1,
      :user => 1,
      :state => "value for state"
    )
  end

  it "renders new request form" do
    render

    response.should have_tag("form[action=?][method=post]", requests_path) do
      with_tag("input#request_term[name=?]", "request[term]")
      with_tag("input#request_position[name=?]", "request[position]")
      with_tag("input#request_user[name=?]", "request[user]")
      with_tag("input#request_state[name=?]", "request[state]")
    end
  end
end
