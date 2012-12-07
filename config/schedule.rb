set :output, { :standard => nil }

every 1.days do
  rake "email_list:build"
  rake "notices"
end

