require 'factory_girl'

Factory.define :answer do |f|
  f.association :request
  f.question { |a| a.association( :question, :quizzes => [ a.request.requestable.quiz ] ) }
  f.content 'blue'
end

Factory.define :authority do |f|
  f.sequence(:name) { |n| "Authority #{n}" }
end

Factory.define :brand do |f|
  f.sequence( :name ) { |n| "Brand #{n}" }
  f.logo { |brand| File.open "#{::Rails.root}/spec/assets/logo.eps" }
end

Factory.define :committee do |f|
  f.sequence(:name) { |n| "Committee #{n}" }
  f.association :schedule
  f.requestable true
end

Factory.define :designee do |f|
  f.association :committee
  f.membership { |d|
    d.association :membership, :position => d.association( :enrollment,
    :position => d.association( :position, :designable => true ),
    :committee => d.committee ).position
  }
  f.association :user
end

Factory.define :enrollment do |f|
  f.association :committee
  f.position { |e| e.association :position, :schedule => e.committee.schedule }
  f.title "member"
  f.votes 1
end

Factory.define :membership do |f|
  f.association :user
  f.association :position
  f.period do |m|
    if m.position.schedule.periods.length > 0
      m.position.schedule.periods.first
    else
      m.position.schedule.reload
      m.association( :period, :schedule => m.position.schedule )
    end
  end
  f.starts_at { |m| m.period.starts_at }
  f.ends_at { |m| m.period.ends_at }
end

Factory.define :current_membership, :parent => :membership do |f|
  f.association :position
  f.period { |m| m.association(:current_period, :schedule => m.position.schedule) }
end

Factory.define :future_membership, :parent => :membership do |f|
  f.association :position
  f.period { |m| m.association(:future_period, :schedule => m.position.schedule) }
end

Factory.define :past_membership, :parent => :membership do |f|
  f.association :position
  f.period { |m| m.association(:past_period, :schedule => m.position.schedule) }
end

Factory.define :motion do |f|
  f.sequence( :name ) { |n| "Motion #{n}" }
  f.association :committee
  f.period do |m|
    if m.committee.schedule.periods.any?
      m.committee.schedule.periods.first
    else
      m.committee.schedule.periods.reset
      m.association( :period, :schedule => m.committee.schedule )
    end
  end
end

Factory.define :motion_merger do |f|
  f.merged_motion { |m| m.association :motion, :status => 'proposed' }
  f.motion do |m|
    m.merged_motion.reload
    m.association :motion, :committee => m.merged_motion.committee, :period => m.merged_motion.period
  end
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
    (periods && periods.last) ? periods.last.starts_at : Time.zone.today
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

Factory.define :meeting do |f|
  f.association :committee
  f.period do |meeting|
    if meeting.committee.schedule.periods.empty?
      meeting.committee.reload
      meeting.association(:period, :schedule => meeting.committee.schedule)
    end
    meeting.committee.schedule.periods.first
  end
  f.starts_at { |m| m.period.starts_at.to_time + 1.hour }
  f.ends_at { |m| m.starts_at + 1.hour }
  f.location 'Day Hall'
end

Factory.define :meeting_motion do |f|
  f.association :meeting
  f.motion do |m|
    m.meeting.reload
    m.association :motion, :committee => m.meeting.committee
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
  f.starts_at { |p| Time.zone.today - 1.year }
  f.ends_at { |p| p.starts_at + 2.years }
end

Factory.define :current_period, :parent => :period do |f|
end

Factory.define :past_period, :parent => :period do |f|
  f.ends_at { |p| Time.zone.today - ( 1.year + 1.day ) }
  f.starts_at { |p| p.ends_at - 1.year }
end

Factory.define :future_period, :parent => :period do |f|
  f.starts_at { |p| Time.zone.today + ( 1.year + 1.day ) }
  f.ends_at { |p| p.starts_at + 1.years }
end

Factory.define :user do |f|
  f.first_name "John"
  f.last_name "Doe"
  f.sequence(:net_id) { |n| "fake_net_id#{n}" }
  f.sequence(:email) { |n| "fake_net_id#{n}@example.com" }
  f.password 'secret'
  f.password_confirmation { |u| u.password }
end

Factory.define :sponsorship do |f|
  f.association :motion
  f.user do |s|
    if s.motion.users.allowed.any?
      s.motion.users.allowed.first
    else
      p = s.association( :position, :schedule => s.motion.committee.schedule )
      s.association( :enrollment, :committee => s.motion.committee, :position => p )
      s.motion.reload; p.reload
      s.association( :membership, :period => s.motion.period, :position => p ).user
    end
  end
end

