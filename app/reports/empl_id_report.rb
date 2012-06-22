class EmplIdReport < MembershipReport
  attr_accessor :memberships

  def initialize(committee, as_of)
    self.memberships = committee.memberships.as_of(as_of).except(:order).
      includes(:user).order('users.last_name ASC, users.first_name ASC').
      where { user_id.not_eq( nil ) }
    super( committee, as_of )
  end

  def rowify_memberships(memberships)
    memberships.uniq.map do |membership|
      [ membership.user.name,
        membership.user.empl_id,
        membership.ends_at.to_s  ]
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
      rows = [ %w( Name EmplID Until ) ]
      table rows, :header => true, :width => 540 do |table|
        table.row(0).background_color = '000000'
        table.row(0).text_color = 'FFFFFF'
        table.cells.padding = 2
        table.columns(1..(table.column_length - 1)).border_left_width = 0.1
        table.columns(0..(table.column_length - 2)).border_right_width = 0.1
        table.rows(0..(table.row_length - 2)).border_bottom_width = 0.1
        table.rows(1..(table.row_length - 1)).border_top_width = 0.1
      end
    end
    render
  end
end

