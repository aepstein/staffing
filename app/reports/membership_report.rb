# Renders PDF membership directory
class MembershipReport < Prawn::Document
  include CustomFonts

  attr_accessor :voting_memberships
  attr_accessor :nonvoting_memberships
  attr_accessor :committee
  attr_accessor :as_of

  LETTERHEAD_CONTACT_OFFSET = 698
  attr_accessor :letterhead_contact_offset

  def initialize(committee, as_of)
    self.committee = committee
    self.as_of = as_of
    memberships = committee.memberships.as_of(as_of).except(:order).
      includes(:user).order('users.last_name ASC, users.first_name ASC')
    self.voting_memberships = memberships.where('enrollments.votes > 0')
    self.nonvoting_memberships = memberships.where('enrollments.votes = 0')
    include_palatino
    super( :page_size => 'LETTER' )
  end

  def draw_letterhead
    brand = committee.brand || Brand.first
    image brand.logo.letterhead.store_path, :height => 72
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

  def rowify_memberships(memberships)
    memberships.uniq.map do |membership|
      core = if membership.user
        [
          membership.user.name,
          membership.user.net_id,
          membership.user.work_address,
          membership.user.mobile_phone
        ]
      else
        [
          'Vacant',
          '-',
          '-',
          '-'
        ]
      end
      core + [ membership.position.enrollments.titles_for_committee(committee),
               membership.ends_at.to_s( :rfc822 ) ]
    end
  end

  def to_pdf
    draw_letterhead
    text "#{committee} Members as of #{as_of.to_s :long_ordinal}",
      align: :center, size: 16
    if as_of != Time.zone.today
      text "(generated #{Time.zone.today.to_s :long_ordinal})", align: :center, size: 10
    end
    font 'Helvetica', :size => 10 do
      rows = [ %w( Name NetID Address Phone Title Until ) ]
      rows << [ 'Voting members', '', '', '', '', '' ]
      rows += rowify_memberships voting_memberships
      section_label_rows = [ 1 ]
      if nonvoting_memberships.length > 0
        section_label_rows << rows.length
        rows << [ 'Non-voting members', '', '', '', '', '' ]
        rows += rowify_memberships nonvoting_memberships
      end
      table rows, :header => true, :width => 540 do |table|
        table.row(0).background_color = '000000'
        table.row(0).text_color = 'FFFFFF'
        table.cells.padding = 2
        table.columns(1..(table.column_length - 1)).border_left_width = 0.1
        table.columns(0..(table.column_length - 2)).border_right_width = 0.1
        table.rows(0..(table.row_length - 2)).border_bottom_width = 0.1
        table.rows(1..(table.row_length - 1)).border_top_width = 0.1
        section_label_rows.each do |section_label_row|
          table.row(section_label_row).background_color = 'DDDDDD'
          table.row(section_label_row).borders = [:top, :bottom]
          table.row(section_label_row).column(0).borders = [ :top, :bottom, :left ]
          table.row(section_label_row).column(5).borders = [ :top, :bottom, :right ]
        end
      end
    end
    render
  end
end

