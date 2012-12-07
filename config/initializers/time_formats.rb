Time::DATE_FORMATS[:us_ordinal] = lambda { |time| time.strftime "%B #{ActiveSupport::Inflector.ordinalize time.day}, %Y %I:%M%P " }
Time::DATE_FORMATS[:short_year] = "%d %b %Y %H:%M"
Time::DATE_FORMATS[:us_time] = "%l:%M%P"

