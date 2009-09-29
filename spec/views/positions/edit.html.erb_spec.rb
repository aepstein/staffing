require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/positions/edit.html.erb" do
  include PositionsHelper

  before(:each) do
    assigns[:position] = @position = stub_model(Position,
      :new_record? => false,
      :authority => 1,
      :committee => 1,
      :quiz => 1,
      :schedule => 1,
      :slots => 1,
      :voting => false,
      :name => "value for name"
    )
  end

  it "renders the edit position form" do
    render

    response.should have_tag("form[action=#{position_path(@position)}][method=post]") do
      with_tag('input#position_authority[name=?]', "position[authority]")
      with_tag('input#position_committee[name=?]', "position[committee]")
      with_tag('input#position_quiz[name=?]', "position[quiz]")
      with_tag('input#position_schedule[name=?]', "position[schedule]")
      with_tag('input#position_slots[name=?]', "position[slots]")
      with_tag('input#position_voting[name=?]', "position[voting]")
      with_tag('input#position_name[name=?]', "position[name]")
    end
  end
end
