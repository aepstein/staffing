# Renders PDF membership directory
class MeetingAgendaReport < AbstractCommitteeReport
  attr_accessor :meeting
  def initialize(meeting)
    self.meeting = meeting
    super( meeting.committee, page_size: 'LETTER' )
  end

  def draw_meeting_section(section)
    bounding_box( [ 0, cursor - 6 ], width: 540 ) do
      text "#{section.position.to_roman}.", style: :bold
      bounding_box( [27, bounds.top], width: 513 ) do
        text "#{section.name}", style: :bold
        section.meeting_items.each { |item| draw_meeting_item item }
      end
    end
  end

  def draw_meeting_item(item)
    bounding_box( [0, cursor - 3 ], width: 486 ) do
      text "#{item.position.to_roman.downcase}."
      bounding_box( [27, bounds.top], width: 486 ) do
        text "#{item.display_name} (#{item.duration} " +
          (item.duration == 1 ? 'minute' : 'minutes') + ")"
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
      meeting.meeting_sections.each { |section| draw_meeting_section section }
    end
    render
  end
end

