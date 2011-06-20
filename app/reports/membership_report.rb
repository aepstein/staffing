# Renders PDF membership directory
class MembershipReport < Prawn::Document
  include CustomFonts

  attr_accessor :memberships

  LETTERHEAD_CONTACT_OFFSET = 698
  attr_accessor :letterhead_contact_offset

  def initialize(memberships=nil)
    self.memberships = memberships unless memberships.nil?
    include_palatino
    super( :page_size => 'LETTER' )
  end

  def draw_letterhead
    image "#{::Rails.root}/public/images/layout/tent/logo.png", :height => 72
    font 'Palatino' do
      text_box '109 Day Hall', :size => 11, :at => [360, 720]
      text_box 'Ithaca, NY 14853', :size => 11, :at => [360, 709]
      draw_letterhead_contact 'p', '607.255.3175'
      draw_letterhead_contact 'f', '607.255.2182'
      draw_letterhead_contact 'e', 'assembly@cornell.edu'
      draw_letterhead_contact 'w', 'http://assembly.cornell.edu'
    end
  end

  def draw_letterhead_contact( letter, content )
    self.letterhead_contact_offset ||= LETTERHEAD_CONTACT_OFFSET
    text_box "#{letter}.", :size => 9, :at => [360, letterhead_contact_offset],
      :width => 18
    text_box content, :size => 9, :at => [378, letterhead_contact_offset]
    self.letterhead_contact_offset -= 9
  end

  def to_pdf
    draw_letterhead
    text "Memberships", :align => :center, :size => 16
    rows = [ %w( Name NetID Address Phone ) ]
    rows += memberships.map do |membership|
      [
        membership.user.name,
        membership.user.net_id,
        membership.user.work_address,
        membership.user.mobile_phone
      ]
    end
#    table rows, :header => true
    render
  end
end

