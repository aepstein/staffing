#!/usr/bin/env ruby

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do

  if notice = UserRenewalNotice.unpopulated.first(true)
    ActiveRecord::Base.logger.info "Populating sendings for #{notice}.\n"
    notice.sendings.populate!
  elsif sending = Sending.incomplete.first(true)
    sending.deliver!
  else
    sleep 10
  end

end

