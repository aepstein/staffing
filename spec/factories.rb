Factory.define :answer do |f|
  f.association :request
  f.question { |a| a.association(:question, :quizzes => [ a.request.position.quiz ]) }
  f.content 'blue'
end

Factory.define :authority do |f|
  f.sequence(:name) { |n| "Authority #{n}" }
end

Factory.define :committee do |f|
  f.sequence(:name) { |n| "Committee #{n}" }
end

Factory.define :designee do |f|
  f.association :committee
  f.membership { |d| d.association :membership, :position => d.association(:enrollment, :committee => d.committee ).position }
  f.association :user
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
  f.period { |m| m.association(:period, :schedule => m.position.schedule) }
  f.starts_at { |m| m.period.starts_at }
  f.ends_at { |m| m.period.ends_at }
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
  f.periods { |r| [ r.position.schedule.periods.first || r.association(:period, :schedule => r.position.schedule) ] }
end

Factory.define :schedule do |f|
  f.sequence(:name) { |n| "Schedule #{n}" }
end

Factory.define :period do |f|
  f.association :schedule
  f.starts_at Date.today
  f.ends_at Date.today + 1.year
end

Factory.define :user do |f|
  f.first_name "John"
  f.last_name "Doe"
  f.sequence(:net_id) { |n| "fake_net_id#{n}" }
  f.sequence(:email) { |n| "fake_net_id#{n}@example.com" }
  f.password 'secret'
  f.password_confirmation { |u| u.password }
end

