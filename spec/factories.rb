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
    logo { File.open "#{::Rails.root}/spec/assets/logo.eps" }
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
    position { association :position, :schedule => committee.schedule }
    title "member"
    votes 1
    requestable false
  end

  factory :membership do
    association :user
    association :position
    period do
      if position.schedule.periods.length > 0
        position.schedule.periods.first
      else
        position.schedule.association(:periods).reset
        association( :period, :schedule => position.schedule )
      end
    end
    starts_at { period.starts_at }
    ends_at { period.ends_at }

    factory :current_membership do
      association :position
      period { association(:current_period, :schedule => position.schedule) }
    end

    factory :future_membership do
      association :position
      period { association(:future_period, :schedule => position.schedule) }
    end

    factory :past_membership do
      association :position
      period { association(:past_period, :schedule => position.schedule) }
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
  end

  factory :motion_merger do
    merged_motion { association :motion, :status => 'proposed' }
    motion do
#      merged_motion.reload
      association :motion, :committee => merged_motion.committee,
        :period => merged_motion.period
    end
  end

  factory :position do
    sequence(:name) { |n| "Position #{n}" }
    association :authority
    association :schedule
    association :quiz
    slots 1
    active true
    factory :renewable_position do
      renewable true
    end
  end

  factory :qualification do
    sequence(:name) { |n| "Qualification #{n}" }
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

  factory :meeting do
    association :committee
    period do
      if committee.schedule.periods.empty?
        committee.schedule.association(:periods).reset
        association(:period, :schedule => committee.schedule)
      end
      committee.schedule.periods.first
    end
    starts_at { period.starts_at + 1.hour }
    ends_at { starts_at + 1.hour }
    location 'Day Hall'
  end

  factory :meeting_motion do
    association :meeting
    motion do
#      meeting.reload
      association :motion, :committee => meeting.committee
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
    sequence(:net_id) { |n| "fake_net_id#{n}" }
    sequence(:email) { |n| "fake_net_id#{n}@example.com" }
    password 'secret'
    password_confirmation { password }
  end

  factory :sponsorship do
    association :motion
    user do
      if motion.users.allowed.any?
        motion.users.allowed.first
      else
        p = association( :position, :schedule => motion.committee.schedule )
        association( :enrollment, :committee => motion.committee, :position => p )
#        motion.reload; p.reload
#        motion.committee.association(:memberships).reset
        association( :membership, :period => motion.period, :position => p ).user
      end
    end
  end
end

