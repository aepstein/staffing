Factory.define :answer do |f|
  f.association :request
  f.question { |a| a.association( :question, :quizzes => [ a.request.requestable.quiz ] ) }
  f.content 'blue'
end

Factory.define :authority do |f|
  f.sequence(:name) { |n| "Authority #{n}" }
end

Factory.define :committee do |f|
  f.sequence(:name) { |n| "Committee #{n}" }
  f.requestable true
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

Factory.define :future_membership, :parent => :membership do |f|
  f.association :position
  f.period { |m| m.association(:future_period, :schedule => m.position.schedule) }
end

Factory.define :past_membership, :parent => :membership do |f|
  f.association :position
  f.period { |m| m.association(:past_period, :schedule => m.position.schedule) }
end

Factory.define :position do |f|
  f.sequence(:name) { |n| "Position #{n}" }
  f.requestable true
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
  f.requestable { |request| request.association :position }
  f.starts_at do |request|
    case request.requestable.class.to_s
    when 'Position'
      periods = request.requestable.schedule.periods
    when 'Committee'
      if position = request.requestable.positions.first
        periods = position.schedule.periods
      else
        periods = false
      end
    else
      periods = false
    end
    (periods && periods.last) ? periods.last.starts_at : Date.today
  end
  f.ends_at do |request|
    case request.requestable.class.to_s
    when 'Position'
      periods = request.requestable.schedule.periods
    when 'Committee'
      if position = request.requestable.positions.first
        periods = position.schedule.periods
      else
        periods = false
      end
    else
      periods = false
    end
    (periods && periods.first) ? periods.first.ends_at : request.starts_at + 1.year
  end
end

Factory.define :expired_request, :parent => :request do |f|
  f.starts_at Date.today - 2.years
end

Factory.define :schedule do |f|
  f.sequence(:name) { |n| "Schedule #{n}" }
end

Factory.define :period do |f|
  f.association :schedule
  f.starts_at Date.today
  f.ends_at { |p| p.starts_at + 1.year }
end

Factory.define :past_period, :parent => :period do |f|
  f.ends_at Date.today - 1.day
  f.starts_at { |p| p.ends_at - 1.year }
end

Factory.define :future_period, :parent => :period do |f|
  f.starts_at Date.today + 1.day
  f.ends_at { |p| p.starts_at + 1.year }
end

Factory.define :user do |f|
  f.first_name "John"
  f.last_name "Doe"
  f.sequence(:net_id) { |n| "fake_net_id#{n}" }
  f.sequence(:email) { |n| "fake_net_id#{n}@example.com" }
  f.password 'secret'
  f.password_confirmation { |u| u.password }
end

Factory.define :user_renewal_notice do |f|
  f.starts_at Date.today
  f.ends_at { |n| n.starts_at + 1.year }
  f.deadline { |n| n.starts_at + 1.week }
end

Factory.define :sending do |f|
  f.association :user
  f.message { |sending| sending.association :user_renewal_notice }
end

