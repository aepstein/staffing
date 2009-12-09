Factory.define :answer do |f|
  f.association :request
  f.association(:question) { |a| Factory(:question, :quiz => a.request.position.quiz) }
  f.content 'blue'
end

Factory.define :authority do |f|
  f.sequence(:name) { |n| "Authority #{n}" }
end

Factory.define :committee do |f|
  f.sequence(:name) { |n| "Committee #{n}" }
end

Factory.define :enrollment do |f|
  f.association :position
  f.association :committee
  f.title "member"
  f.votes 1
end

Factory.define :membership do |f|
  f.association :user
  f.association :position
  f.association(:term) { |m| Factory(:term, :schedule => m.position.schedule) }
  f.starts_at { |m| m.term.starts_at }
  f.ends_at { |m| m.term.ends_at }
end

Factory.define :position do |f|
  f.sequence(:name) { |n| "Position #{n}" }
  f.association :authority
  f.association :schedule
  f.association :quiz
  f.slots 1
end

Factory.define :qualification do |f|
  f.sequence(:name) { |n| "Qualification #{n}" }
end

Factory.define :question do |f|
  f.sequence(:name) { |n| "Question #{n}" }
  f.content "What is your favorite color?"
end

Factory.define :quiz do |f|
  f.sequence(:name) { |n| "Quiz #{n}" }
end

Factory.define :request do |f|
  f.association :user
  f.association :position
  f.association(:term) { |r| Factory(:term, :schedule => r.position.schedule) }
end

Factory.define :schedule do |f|
  f.sequence(:name) { |n| "Schedule #{n}" }
end

Factory.define :term do |f|
  f.association :schedule
  f.starts_at Date.today
  f.ends_at Date.today + 1.year
end

Factory.define :user do |f|
  f.sequence(:net_id) { |n| "jd#{n}" }
  f.first_name "John"
  f.last_name "Doe"
  f.email "jd@example.com"
end

