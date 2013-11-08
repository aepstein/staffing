require "spring/commands/rspec"
require "spring/commands/cucumber"
Spring.after_fork do
  if ::Rails.env == 'test'
    FactoryGirl.reload if defined?( FactoryGirl )
  end
end

