Spork.prefork do
  require File.dirname(__FILE__) + '/../../spec/factories'
  require 'pickle/world'
  # Example of configuring pickle:
  #
  # Pickle.configure do |config|
  #   config.adapters = [:machinist]
  #   config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
  # end
end

