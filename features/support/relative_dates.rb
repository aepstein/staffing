module RelativeDates

  def relative_date(match)
    match =~ /^(\d+) (days?|weeks?|months?) (before|after) (now|today)$/
    origin = Time.zone.send($4)
    modifier = $1.to_i.send($2)
    if $3 == 'before'
      origin - modifier
    else
      origin + modifier
    end
  end

end

World(RelativeDates)

class << self
  def capture_relative_date
    '(\d+ (?:days?|weeks?|months?) (?:before|after) (?:now|today))'
  end
end

