#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do
  $running = false
end

while($running) do

  UserRenewalNotice.unpopulated.each do |notice|
    ActiveRecord::Base.logger.info "Populating sendings for #{notice}.\n"
    notice.sendings.populate!
  end

  sleep 10
end

