# Renders PDF membership directory
class MeetingAgendaReport < AbstractCommitteeReport
  include MeetingsHelper

  attr_accessor :meeting
  def initialize(meeting)
    self.meeting = meeting
    super( meeting.committee, page_size: 'LETTER' )
  end

  def draw_meeting_section(section, position)
    span(540, position: :right) do
      text "#{position.to_roman}.", style: :bold
    end
    move_up 14
    span(504, position: :right) do
      text "#{section.name}", style: :bold
    end
    i = 1;
    section.meeting_items.each { |item| draw_meeting_item( item, i ); i += 1 }
  end

  def draw_meeting_item(item, position)
    span(504, position: :right ) do
      text "#{position.to_roman.downcase}."
    end
    move_up 14
    span(468, position: :right ) do
      text "#{item.display_name} (#{item.duration} " +
        (item.duration == 1 ? 'minute' : 'minutes') + ") <sup>" +
        footnotes_for_meeting_item_attachments( meeting, item, format: :text ) +
        "</sup>",
        inline_format: true
    end
  end
  
  def draw_meeting_attachments
    span(540, position: :right) do
      text "Attachments", style: :bold
    end
    move_down 12
    meeting.attachments.values.flatten.each do |attachment|
      span(504, position: :right) do
        text "#{meeting.attachment_index(attachment)}."
      end
      move_up 14
      span(468, position: :right) do
        text footnote_for_meeting_attachment( meeting, attachment, format: :pdf )
      end
    end
  end

  def to_pdf
    draw_letterhead
    move_down 12
    text "Agenda", align: :center, size: 18
    text committee.name, align: :center, size: 12
    text meeting.starts_at.to_date.to_formatted_s(:long_ordinal),
      align: :center, size: 12
    text meeting.to_s(:time), align: :center, size: 12
    text meeting.location, align: :center, size: 12
    move_down 24
    font 'Helvetica', size: 12 do
      i = 1;
      meeting.meeting_sections.each { |section| draw_meeting_section( section, i ); i += 1 }
      move_down 12
      draw_meeting_attachments
    end
    number_pages "#{accommodations_text}Page <page> of <total>",
      align: :center, style: :italic, size: 10, width: 540, at: [ 0, 0 ]
    render
  end
end

