class AbstractCommitteeReport < Prawn::Document
  include CustomFonts

  attr_accessor :committee
  attr_accessor :letterhead_contact_offset
  LETTERHEAD_CONTACT_OFFSET = 720
  LETTERHEAD_TEXT_START = 324

  def self.markup_markdown( source )
    out = source.clone
    {
      '\*\*' => 'b',
      '__' => 'b',
      '\+\+' => 'u',
      '\-\-' => 'strikethrough',
      '\*' => 'i',
      '_' => 'i'
    }.each do |mark, tag|
      out.gsub! /#{mark}([^#{mark}]+)#{mark}/, "<#{tag}>\\1</#{tag}>"
    end
    {
      '\+' => 'u',
      '\-' => 'strikethrough'
    }.each do |mark, tag|
      out.gsub! /\[#{mark}([^#{mark}]+)#{mark}\]/, "<#{tag}>\\1</#{tag}>"
    end
    out
  end

  def initialize(committee, options = {})
    self.committee = committee
    include_palatino
    super( options.merge( { page_size: 'LETTER', bottom_margin: 108 } ) )
  end

  def contact_attributes
    @contact_attributes ||= committee.contact_attributes
  end

  def letterhead_height
    self.letterhead_contact_offset ||= LETTERHEAD_CONTACT_OFFSET
    LETTERHEAD_CONTACT_OFFSET - letterhead_contact_offset
  end

  def draw_letterhead
    brand = committee.brand || Brand.first
    image brand.logo.letterhead.store_path, height: 72, at: [ 0,720 ]
    font 'Palatino' do
      draw_letterhead_address contact_attributes[:address_1]
      draw_letterhead_address contact_attributes[:address_2] if contact_attributes[:address_2]
      draw_letterhead_address "#{contact_attributes[:city]}, #{contact_attributes[:state]} #{contact_attributes[:zip]}"
      draw_letterhead_contact 'p', contact_attributes[:phone].to_phone(:dotty)
      draw_letterhead_contact 'f', contact_attributes[:fax].to_phone(:dotty)
      draw_letterhead_contact 'e', contact_attributes[:email]
      draw_letterhead_contact 'w', contact_attributes[:web]
    end
    move_down [ 72, letterhead_height ].max
  end

  def accommodations_text
    "If you are in need of special accommodations, contact Office of the " +
    "Assemblies at (607) 255-3715 or Student Disability Services at (607) " +
    "254-4545 prior to the meeting.\n"
  end

  def draw_letterhead_address( text )
    self.letterhead_contact_offset ||= LETTERHEAD_CONTACT_OFFSET
    text_box text, size: 11, at: [ LETTERHEAD_TEXT_START, letterhead_contact_offset ]
    self.letterhead_contact_offset -= 13
  end

  def draw_letterhead_contact( letter, content )
    self.letterhead_contact_offset ||= LETTERHEAD_CONTACT_OFFSET
    text_box "#{letter}.", size: 9, at: [LETTERHEAD_TEXT_START, letterhead_contact_offset],
      width: 18
    text_box content, size: 9, at: [LETTERHEAD_TEXT_START + 18, letterhead_contact_offset]
    self.letterhead_contact_offset -= 10
  end

  def draw_line_numbers( from, to )
    lines = ( ( from - to + 12 ) / 12 ).floor
    text_box "#{(1..lines).to_a.join("\n")}", at: [ 0, from ], width: 18,
      height: ( from - to )
  end
end

