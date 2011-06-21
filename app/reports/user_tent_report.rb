# Renders PDF "tent card" for one or more users
# If printed on card stock and folded down long axis, these card can be used as
# placards at meetings
# TODO: Implement logo interface to allow customization of logo used in cards
class UserTentReport < Prawn::Document
  attr_accessor :users

  def initialize(users=nil)
    self.users = users unless users.nil?
    super( :page_size => 'LETTER', :page_layout => :landscape )
  end

  def to_pdf
    user = users.shift
    rotate 180, :origin => [720,306] do
      bounding_box [720,306], :width => 720, :height => 234 do
        image "#{::Rails.root}/public/images/layout/tent/logo.png", :height => 72
        text user.name, :size => 48, :align => :center
      end
    end
    bounding_box [0,234], :width => 720, :height => 234 do
      image "#{::Rails.root}/public/images/layout/tent/logo.png", :height => 72
      text user.name, :size => 48, :align => :center
    end
    unless users.empty?
      start_new_page
      to_pdf
    end
    render
  end
end

