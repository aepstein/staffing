class AbstractCommitteeReport < Prawn::Document
  include CustomFonts

  attr_accessor :committee
  attr_accessor :letterhead_contact_offset
  LETTERHEAD_CONTACT_OFFSET = 698

  def initialize(committee, options = {})
    self.committee = committee
    include_palatino
    super( options.merge( { page_size: 'LETTER' } ) )
  end

  def draw_letterhead
    brand = committee.brand || Brand.first
    image brand.logo.letterhead.store_path, height: 72
    font 'Palatino' do
      text_box Staffing::Application.app_config['defaults']['contact']['address_1'], size: 11, at: [360, 720]
      text_box Staffing::Application.app_config['defaults']['contact']['address_2'], size: 11, at: [360, 709]
      draw_letterhead_contact 'p', Staffing::Application.app_config['defaults']['contact']['phone']
      draw_letterhead_contact 'f', Staffing::Application.app_config['defaults']['contact']['fax']
      draw_letterhead_contact 'e', Staffing::Application.app_config['defaults']['contact']['email']
      draw_letterhead_contact 'w', Staffing::Application.app_config['defaults']['contact']['web']
    end
  end

  def draw_letterhead_contact( letter, content )
    self.letterhead_contact_offset ||= LETTERHEAD_CONTACT_OFFSET
    text_box "#{letter}.", size: 9, at: [360, letterhead_contact_offset],
      width: 18
    text_box content, size: 9, at: [378, letterhead_contact_offset]
    self.letterhead_contact_offset -= 9
  end
end

