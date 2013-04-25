# Renders PDF membership directory
class MotionCommentReport < AbstractCommitteeReport
  attr_accessor :motion
  def initialize(motion)
    self.motion = motion
    super( motion.committee, page_size: 'LETTER' )
  end

  def comments
    i = 0
    @comments ||=  motion.motion_comments.to_a.inject({}) do |memo, comment|
      i += 1
      memo["#{i}. #{comment.user.name( :net_id )}"] = comment
      memo
    end
  end

  def render_comment( title, comment )
    text title, size: 16
    font 'Helvetica', size: 12, kerning: true, style: :italic do
      text "Created: #{comment.created_at.to_s(:long_ordinal)}, Updated: #{comment.updated_at.to_s(:long_ordinal)}"
    end
    move_down 12
    text comment.comment
  end

  def to_pdf
    draw_letterhead
    move_down 12
    text "Comments for #{motion.to_s :full}", align: :center, size: 18
    font 'Helvetica', size: 12, kerning: true, style: :italic do
      text "Last Updated: #{motion.motion_comments.maximum(:updated_at).to_s :long_ordinal}", align: :right
      text "End of Comment Period: #{motion.comment_until.to_s :long_ordinal}", align: :right
    end
    move_down 12
    comments.each do |title, comment|
      render_comment title, comment
      start_new_page unless comment = motion.motion_comments.last
    end
    font 'Helvetica', size: 12, kerning: true do
      number_pages "Page <page> of <total>", align: :center, style: :italic,
        size: 10, width: 540, at: [ 0, 0 ]
    end
    render
  end
end

