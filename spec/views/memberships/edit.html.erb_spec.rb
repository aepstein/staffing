require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/memberships/edit.html.erb" do
  include MembershipsHelper

  before(:each) do
    assigns[:membership] = @membership = stub_model(Membership,
      :new_record? => false,
      :user => 1,
      :term => 1,
      :position => 1,
      :request => 1
    )
  end

  it "renders the edit membership form" do
    render

    response.should have_tag("form[action=#{membership_path(@membership)}][method=post]") do
      with_tag('input#membership_user[name=?]', "membership[user]")
      with_tag('input#membership_term[name=?]', "membership[term]")
      with_tag('input#membership_position[name=?]', "membership[position]")
      with_tag('input#membership_request[name=?]', "membership[request]")
    end
  end
end
