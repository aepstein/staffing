require 'factory_girl'

FactoryGirl.define do
  factory :answer do
    association :membership_request
    question do |a|
      a.association( :question,
        quiz_questions: [ FactoryGirl.build(:quiz_question,
          quiz: a.membership_request.requestable_positions.assignable.first.quiz,
          question: nil) ] )
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
    duration 60
    location 'Day Hall'

    factory :current_meeting do
      starts_at { Time.zone.now - 1.hour }
      duration 120
    end

    factory :recent_meeting do
      starts_at { Time.zone.now - 1.day }
    end

    factory :pending_meeting do
      starts_at { Time.zone.now + 1.day }
    end
  end

  factory :meeting_section do
    association :meeting
    sequence(:name) { |i| "Section #{i}" }
    sequence(:position) { |i| i }
  end

  factory :meeting_section_template do
    association :meeting_template
    sequence(:name) { |i| "Meeting Section Template #{i}" }
    sequence(:position) { |i| i }
  end

  factory :meeting_template do
    sequence(:name) { |i| "Meeting Template #{i}" }
  end

  factory :meeting_item do
    association :meeting_section
    sequence(:name) { |i| "Item #{i}" }
    duration 10
    sequence(:position) { |i| i }

    factory :motion_meeting_item do
      name nil
      motion do |item|
        FactoryGirl.create(:motion, period: item.meeting_section.meeting.period,
          committee: item.meeting_section.meeting.committee)
      end
    end
  end

  factory :meeting_item_template do
    association :meeting_section_template
    sequence(:name) { |i| "Meeting Item Template #{i}" }
    sequence(:position) { |i| i }
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

  factory :membership_request do
    association :user
    committee { |membership_request| membership_request.association :requestable_committee }
    starts_at { Time.zone.today }
    ends_at { |membership_request| membership_request.starts_at + 1.year }
    factory :expired_membership_request do
      starts_at Time.zone.today - 2.years
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
    factory :meeting_motion do
      meeting { association(:meeting, committee: committee, period: period) }
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

  factory :motion_comment do
    association :motion, status: 'proposed'
    association :user
    comment 'I wish to comment.'
  end

  factory :motion_meeting_segment do
    motion { association :meeting_motion }
    position 1
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
  
  factory :notice do
    notifiable { FactoryGirl.create(:membership) }
    event 'join'
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

  factory :quiz_question do
    association(:quiz)
    association(:question)
    position 1
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

