require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/requests/edit.html.erb" do
  include RequestsHelper

  before(:each) do
    assigns[:request] = @request = stub_model(Request,
      :new_record? => false,
      :term => 1,
      :position => 1,
      :user => 1,
      :state => "value for state"
    )
  end

  it "renders the edit request form" do
    render

    response.should have_tag("form[action=#{request_path(@request)}][method=post]") do
      with_tag('input#request_term[name=?]', "request[term]")
      with_tag('input#request_position[name=?]', "request[position]")
      with_tag('input#request_user[name=?]', "request[user]")
      with_tag('input#request_state[name=?]', "request[state]")
    end
  end
end
