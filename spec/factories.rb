require 'factory_girl'

FactoryGirl.define do
  factory :answer do |f|
    association :request
    question { |a| a.association( :question, :quizzes => [ a.request.requestable.quiz ] ) }
    content 'blue'
  end

  factory :authority do |f|
    sequence(:name) { |n| "Authority #{n}" }
  end

  factory :brand do |f|
    sequence( :name ) { |n| "Brand #{n}" }
    logo { |brand| File.open "#{::Rails.root}/spec/assets/logo.eps" }
  end

  factory :committee do |f|
    sequence(:name) { |n| "Committee #{n}" }
    association :schedule
    requestable true
  end

  factory :designee do |f|
    association :committee
    membership { |d|
      d.association :membership, :position => d.association( :enrollment,
      :position => d.association( :position, :designable => true ),
      :committee => d.committee ).position
    }
    association :user
  end

  factory :enrollment do |f|
    association :committee
    position { |e| e.association :position, :schedule => e.committee.schedule }
    title "member"
    votes 1
  end

  factory :membership do |f|
    association :user
    association :position
    period do |m|
      if m.position.schedule.periods.length > 0
        m.position.schedule.periods.first
      else
        m.position.schedule.reload
        m.association( :period, :schedule => m.position.schedule )
      end
    end
    starts_at { |m| m.period.starts_at }
    ends_at { |m| m.period.ends_at }

    factory :current_membership do |f|
      association :position
      period { |m| m.association(:current_period, :schedule => m.position.schedule) }
    end

    factory :future_membership do |f|
      association :position
      period { |m| m.association(:future_period, :schedule => m.position.schedule) }
    end

    factory :past_membership do |f|
      association :position
      period { |m| m.association(:past_period, :schedule => m.position.schedule) }
    end
  end

  factory :motion do |f|
    sequence( :name ) { |n| "Motion #{n}" }
    association :committee
    period do |m|
      if m.committee.schedule.periods.any?
        m.committee.schedule.periods.first
      else
        m.committee.schedule.periods.reset
        m.association( :period, :schedule => m.committee.schedule )
      end
    end
  end

  factory :motion_merger do |f|
    merged_motion { |m| m.association :motion, :status => 'proposed' }
    motion do |m|
      m.merged_motion.reload
      m.association :motion, :committee => m.merged_motion.committee, :period => m.merged_motion.period
    end
  end

  factory :position do |f|
    sequence(:name) { |n| "Position #{n}" }
    requestable true
    association :authority
    association :schedule
    association :quiz
    slots 1
  end

  factory :qualification do |f|
    sequence(:name) { |n| "Qualification #{n}" }
  end

  factory :question do |f|
    sequence(:name) { |n| "Question #{n}" }
    content "What is your favorite color?"
  end

  factory :quiz do |f|
    sequence(:name) { |n| "Quiz #{n}" }
  end

  factory :request do |f|
    association :user
    requestable { |request| request.association :position }
    starts_at do |request|
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
    ends_at do |request|
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
    factory :expired_request do |f|
      starts_at Date.today - 2.years
    end
  end

  factory :meeting do |f|
    association :committee
    period do |meeting|
      if meeting.committee.schedule.periods.empty?
        meeting.committee.reload
        meeting.association(:period, :schedule => meeting.committee.schedule)
      end
      meeting.committee.schedule.periods.first
    end
    starts_at { |m| m.period.starts_at.to_time + 1.hour }
    ends_at { |m| m.starts_at + 1.hour }
    location 'Day Hall'
  end

  factory :meeting_motion do |f|
    association :meeting
    motion do |m|
      m.meeting.reload
      m.association :motion, :committee => m.meeting.committee
    end
  end

  factory :schedule do |f|
    sequence(:name) { |n| "Schedule #{n}" }
  end

  factory :period do |f|
    association :schedule
    starts_at { |p| Time.zone.today - 1.year }
    ends_at { |p| p.starts_at + 2.years }

    factory :current_period do |f|
    end

    factory :past_period do |f|
      ends_at { |p| Time.zone.today - ( 1.year + 1.day ) }
      starts_at { |p| p.ends_at - 1.year }
    end

    factory :future_period do |f|
      starts_at { |p| Time.zone.today + ( 1.year + 1.day ) }
      ends_at { |p| p.starts_at + 1.years }
    end

  end

  factory :user do |f|
    first_name "John"
    last_name "Doe"
    sequence(:net_id) { |n| "fake_net_id#{n}" }
    sequence(:email) { |n| "fake_net_id#{n}@example.com" }
    password 'secret'
    password_confirmation { |u| u.password }
  end

  factory :sponsorship do |f|
    association :motion
    user do |s|
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
end

