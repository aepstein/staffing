# Renders PDF membership directory
class MotionReport < AbstractCommitteeReport
  attr_accessor :motion, :first_line_at
  def initialize(motion)
    self.motion = motion
    super( motion.committee, page_size: 'LETTER' )
  end

  def sponsors
    @sponsors ||= motion.users_for(:sponsors, include_referrers: true)
  end

  def last_event
    motion.motion_events.last
  end

  def draw_line_numbers( from, to )
    lines = ( ( from - to + 12 ) / 12 ).floor
    text_box "#{(1..lines).to_a.join("\n")}", at: [ 0, from ], width: 18,
      height: ( from - to )
  end

  def to_pdf
    draw_letterhead
    move_down 12
    text "#{motion.to_s :full}", align: :center, size: 18
    font 'Helvetica', size: 12, kerning: true, style: :italic do
      if sponsors.any?
        if sponsors.length > 1
          text "Sponsors: #{sponsors.listify}", align: :right
        else
          text "Sponsor: #{sponsors.listify}", align: :right
        end
      end
      if last_event
        text "#{last_event.event.titleize} on #{last_event.occurrence.to_s :long_ordinal}", align: :right
      end
    end
    move_down 12
    self.first_line_at = cursor
    font 'Helvetica', size: 12, kerning: true do
      span( 504, position: :right ) do
        text( ( motion.content? ? motion.content : "" ))
      end
      if page_number > 1
        draw_line_numbers 720, cursor
        repeat([1]) do
          draw_line_numbers first_line_at, 0
        end
        if page_number > 2
          repeat( 2..(page - 1) ) do
            draw_line_numbers 720, 0
          end
        end
      else
        draw_line_numbers first_line_at, cursor
      end
      number_pages "Page <page> of <total>", align: :center, style: :italic,
        size: 10, width: 540, at: [ 0, 0 ]
    end
    render
  end
end
