# Renders PDF membership directory
class MeetingAgendaReport < AbstractCommitteeReport
  attr_accessor :meeting
  def initialize(meeting)
    self.meeting = meeting
    super( meeting.committee, page_size: 'LETTER' )
  end

  def to_pdf
    draw_letterhead
    text "Agenda", align: :center, size: 16
    text committee.name, align: :center, size: 12
    text meeting.starts_at.to_date.to_formatted_s(:long_ordinal),
      align: :center, size: 12
    text meeting.starts_at.to_formatted_s(:us_time) + " - " +
      meeting.ends_at.to_formatted_s(:us_time), align: :center, size: 12
    text meeting.location, align: :center, size: 12
    font 'Helvetica', size: 11 do
      meeting.meeting_sections.each do |section|
        text "#{section.position.to_roman}. #{section.name}"
        section.meeting_items.each do |item|
          text "#{item.position.to_roman.downcase}. #{item.name} (#{item.duration} minutes)"
        end
      end
    end
    render
  end
end

