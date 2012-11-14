require 'factory_girl'

FactoryGirl.define do
  factory :answer do
    association :request
    question do |a|
      a.association( :question,
        :quizzes => [a.request.requestable_positions.assignable.first.quiz] )
    end
    content 'blue'
  end

  factory :attachment do
    association :attachable, factory: :motion
    document { File.open "#{::Rails.root}/spec/assets/empl_ids.csv" }
    sequence(:description) { |n| "Document #{n}" }
  end

  factory :authority do
    sequence(:name) { |n| "Authority #{n}" }
  end

  factory :brand do
    sequence( :name ) { |n| "Brand #{n}" }
    logo { File.open "#{::Rails.root}/spec/assets/logo.svg" }
  end

  factory :committee do
    sequence(:name) { |n| "Committee #{n}" }
    association :schedule
    active true

    factory :requestable_committee do
      after(:create) do |committee, evaluator|
        FactoryGirl.create( :enrollment, committee: committee,
          position: FactoryGirl.create(:position, schedule: committee.schedule),
          requestable: true )
      end
    end
  end

  factory :designee do
    association :committee
    membership {
      association :membership, :position => association( :enrollment,
      :position => association( :position, :designable => true ),
      :committee => committee ).position
    }
    association :user
  end

  factory :enrollment do
    association :committee
    position { association :position, schedule: committee.schedule }
    title "member"
    votes 1
    requestable false
    factory :requestable_enrollment do
      requestable true
    end
  end

  factory :meeting do
    association :committee
    period do
      if committee.schedule.periods.empty?
        committee.schedule.association(:periods).reset
        association(:period, schedule: committee.schedule)
      end
      committee.schedule.periods.first
    end
    starts_at { period.starts_at + 1.hour }
    ends_at { starts_at + 1.hour }
    location 'Day Hall'

    factory :current_meeting do
      starts_at { Time.zone.now - 1.hour }
      ends_at { Time.zone.now + 1.hour }
    end

    factory :recent_meeting do
      starts_at { Time.zone.now - 1.day }
      ends_at { ( Time.zone.now - 1.day ) + 1.hour }
    end

    factory :pending_meeting do
      starts_at { Time.zone.now + 1.day }
    end
  end

  factory :meeting_motion do
    association :meeting
    motion do
#      meeting.reload
      association :motion, committee: meeting.committee
    end
  end

  factory :membership do
    association :user
    association :position
    period do
      if position.schedule.periods.length > 0
        position.schedule.periods.first
      else
        position.schedule.association(:periods).reset
        association( :period, schedule: position.schedule )
      end
    end
    starts_at { period.starts_at }
    ends_at { period.ends_at }

    factory :renewable_membership do
      association :position, renewable: true
      renew_until { |m| m.period.ends_at + 1.year }
    end

    factory :current_membership do
      period { association(:current_period, schedule: position.schedule) }

      factory :recent_membership do
        ends_at { Time.zone.today - 2.days }
      end

      factory :pending_membership do
        starts_at { Time.zone.today + 2.days }
      end
    end

    factory :future_membership do
      period { association(:future_period, schedule: position.schedule) }
    end

    factory :past_membership do
      period { association(:past_period, schedule: position.schedule) }
    end
  end

  factory :motion do
    sequence( :name ) { |n| "Motion #{n}" }
    association :committee
    period do
      if committee.schedule.periods.any?
        committee.schedule.periods.first
      else
        committee.schedule.association(:periods).reset
        association( :period, :schedule => committee.schedule )
      end
    end
    factory :referred_motion do
      referring_motion do |motion|
        FactoryGirl.create( :sponsored_motion,
          status: 'proposed',
          committee: FactoryGirl.create(:committee, schedule: motion.committee.schedule ),
          period: motion.period )
      end
    end
    factory :sponsored_motion do
      after(:build) do |motion|
        motion.sponsorships << [ FactoryGirl.build(:sponsorship, motion: motion) ]
      end
    end
  end

  factory :motion_event do
    association :motion, status: 'proposed'
    occurrence { Time.zone.today }
    event { 'propose' }
  end

  factory :motion_merger do
    merged_motion { association :motion, status: 'proposed' }
    motion do
      association :motion, committee: merged_motion.committee,
        period: merged_motion.period, status: 'proposed'
    end
  end

  factory :position do
    sequence(:name) { |n| "Position #{n}" }
    association :authority
    association :schedule
    association :quiz
    slots 1
    minimum_slots { slots }
    active true
    factory :renewable_position do
      renewable true
    end
  end

  factory :question do
    sequence(:name) { |n| "Question #{n}" }
    content "What is your favorite color?"
  end

  factory :quiz do
    sequence(:name) { |n| "Quiz #{n}" }
  end

  factory :request do
    association :user
    committee { |request| request.association :requestable_committee }
    starts_at { Time.zone.today }
    ends_at { |request| request.starts_at + 1.year }
    factory :expired_request do
      starts_at Time.zone.today - 2.years
    end
  end

  factory :schedule do
    sequence(:name) { |n| "Schedule #{n}" }
  end

  factory :period do
    association :schedule
    starts_at { Time.zone.today - 1.year }
    ends_at { starts_at + 2.years }

    factory :current_period do
    end

    factory :past_period do
      starts_at { Time.zone.today - 2.years }
      ends_at { Time.zone.today - ( 1.year + 1.day ) }
    end

    factory :future_period do
      starts_at { Time.zone.today + ( 1.year + 1.day ) }
      ends_at { starts_at + 1.years }
    end

  end

  factory :user do
    first_name "John"
    last_name "Doe"
    sequence(:net_id) { |n| "fake#{n}" }
    sequence(:email) { |n| "fake#{n}@example.com" }
    password 'secret'
    password_confirmation { password }
  end

  factory :sponsorship do
    association :motion
    user do
      p = association( :position, :schedule => motion.committee.schedule )
      association( :enrollment, :committee => motion.committee, :position => p )
      association( :membership, :period => motion.period, :position => p ).user
    end
  end
end

