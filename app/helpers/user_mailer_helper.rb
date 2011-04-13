module UserMailerHelper
  def format_end_date(period)
    if period.ends_at < Time.zone.today
      "that ended on #{period.ends_at.to_s :long_ordinal}"
    else
      "that ends on #{period.ends_at.to_s :long_ordinal}"
    end
  end
end

