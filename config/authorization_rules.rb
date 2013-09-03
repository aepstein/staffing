authorization do
  role :admin do
    has_permission_on [ :authorities, :brands, :committees,
      :meetings, :meeting_templates, :memberships, :motions, :motion_comments,
      :positions, :quizzes, :questions, :membership_requests, :schedules, :users,
      :user_renewal_notices, :sendings ],
      to: [ :manage ]

    includes :staff
  end
  role :staff do
    has_permission_on [ :attachments, :authorities, :brands, :committees,
      :meetings, :meeting_templates, :memberships, :motions, :motion_comments,
      :positions, :quizzes, :questions, :membership_requests, :schedules, :users,
      :user_renewal_notices, :sendings ],
      to: [ :create, :update, :show, :index, :staff ]
    has_permission_on :committees, to: [ :chair, :clerk, :members, :tents, :vote ]
    has_permission_on :memberships, to: [ :staff ]
    has_permission_on :memberships, to: [ :decline ] do
      if_attribute declined_at: is { nil }, starts_at: lte { Time.zone.today },
        renew_until: is_not { nil }, position: { renewable: true }
    end
    has_permission_on :meetings, to: [ :publish, :staff ]
    has_permission_on :meetings, to: [ :destroy ] do
      if_attribute period: { ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :admin, :adopt, :amend, :divide,
      :implement, :merge, :propose, :refer, :reject, :restart, :withdraw,
      :comment ]
    has_permission_on :motion_comments, to: [ :update ]
    has_permission_on :users, to: [ :resume, :staff, :tent ]
    has_permission_on :membership_requests, to: [ :reject, :reactivate ]

    includes :user
  end
  role :authority do
    has_permission_on :users, to: :show
  end
  role :user do
    has_permission_on [ :authorities, :brands, :committees, :meeting_templates,
      :memberships, :motion_comments, :positions, :schedules ],
      to: [ :show, :index ]
    has_permission_on [ :motions, :membership_requests ], to: :index
    has_permission_on :committees, to: :vote do
      if_attribute enrollments: {
        position_id: is_in { user.memberships.current.value_of(:position_id) },
        votes: gt { 0 } }
    end
    has_permission_on :committees, to: :sponsor, join_by: :and do
      if_permitted_to :vote
      if_attribute sponsor: is { true }
    end
    has_permission_on :committees, to: :clerk, join_by: :and do
      if_attribute enrollments: {
        id: is_in { user.enrollments.current.with_roles('clerk').value_of(:id) } }
    end
    has_permission_on :committees, to: :chair do
      if_attribute enrollments: {
        id: is_in { user.enrollments.current.with_roles('chair').value_of(:id) } }
    end
    has_permission_on :committees, to: :vicechair do
      if_attribute enrollments: {
        id: is_in { user.enrollments.current.with_roles('vicechair').value_of(:id) } }
    end
    has_permission_on :committees, to: :enroll, join_by: :or do
      if_attribute enrollments: {
        position_id: is_in { user.memberships.current.value_of(:position_id) } }
    end
    has_permission_on :meetings, to: :clerk do
      if_permitted_to :clerk, :committee
    end
    has_permission_on :meetings, to: :show do
      if_permitted_to :vicechair, :committee
    end
    has_permission_on :meetings, to: [:create, :update, :publish], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute period: { starts_at: lte { Time.zone.today },
        ends_at: gte { Time.zone.today } }
    end
    has_permission_on :meetings, to: [:destroy], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute period: { starts_at: lte { Time.zone.today },
        ends_at: gte { Time.zone.today } }
      if_attribute starts_at: gte { Time.zone.today.to_time }
    end
    has_permission_on :memberships, to: [ :create ], join_by: :and do
      if_attribute position: { authority: { authorized_enrollments: {
          votes: gt { 0 },
          memberships: {
            user_id: is { user.id },
            ends_at: gte { Time.zone.today }
        } } } }
    end
    has_permission_on :memberships, to: [ :update ], join_by: :and do
      if_attribute position: { authority: { authorized_enrollments: {
          votes: gt { 0 },
          memberships: {
            user_id: is { user.id },
            starts_at: lte { object.ends_at },
            ends_at: gte { [ object.starts_at, Time.zone.today ].max }
        } } } }
      if_attribute period: { ends_at: gte { Time.zone.today } }
    end
    has_permission_on :memberships, to: [ :decline ], join_by: :and do
      if_attribute declined_at: is { nil }, starts_at: lte { Time.zone.today },
        renew_until: gte { Time.zone.today }, position: {
        authority: { authorized_enrollments: {
        votes: gt { 0 },
        memberships: {
        user_id: is { user.id },
        starts_at: lte { object.renew_until },
        ends_at: gt { object.ends_at }
      } } } }
    end
    has_permission_on :membership_requests, to: [ :manage, :show ] do
      if_attribute user_id: is { user.id }
    end
    has_permission_on :membership_requests, to: [ :show ] do
      if_attribute committee_id: is_in { user.committees.authorized(0).map(&:id) }
    end
    has_permission_on :membership_requests, to: [ :reject ] do
      if_attribute committee_id: is_in { user.committees.authorized.map(&:id) }
    end
    has_permission_on :motions, to: :own do
      if_attribute sponsorships: { user_id: is { user.id } }
    end
    has_permission_on :motions, to: :create, join_by: :and do
      if_permitted_to :sponsor, :committee
      if_attribute period_id: is { nil }
    end
    has_permission_on :motions, to: :create, join_by: :and do
      if_permitted_to :clerk, :meeting
      if_attribute period_id: is { nil }
    end
    has_permission_on :motions, to: :create, join_by: :and do
      if_permitted_to :sponsor, :committee
      if_attribute period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: :create, join_by: :and do
      if_permitted_to :clerk, :meeting
      if_attribute period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: :update, join_by: :and do
      if_permitted_to :own
      if_attribute status: is { 'started' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :update, :propose ], join_by: :and do
      if_permitted_to :clerk, :meeting
      if_attribute status: is { 'started' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: :watch do
      if_attribute published: true, watchers: does_not_contain { user }
    end
    has_permission_on :motions, to: :unwatch do
      if_attribute watchers: contains { user }
    end
    has_permission_on :motions, to: :show do
      if_attribute sponsorships: { user_id: is { user.id } }
      if_permitted_to :clerk, :meeting
    end
    has_permission_on :motions, to: [ :propose, :withdraw ], join_by: :and do
      if_permitted_to :vote, :committee
      if_permitted_to :own
    end
    has_permission_on :motions, to: [ :restart ], join_by: :and do
      if_permitted_to :vote, :committee
      if_permitted_to :own
      if_attribute status: is { 'withdrawn' }
    end
    has_permission_on :motions, to: :withdraw, join_by: :and do
      if_permitted_to :vote, :committee
      if_permitted_to :own
    end
    has_permission_on :motions, to: [ :propose, :show, :update ], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute status: is { 'started' }, referring_motion_id: is_not { nil },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :propose, :show, :update ], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute status: is { 'started' }, meeting_id: is_not { nil },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :adopt, :amend, :divide, :merge, :reject,
      :refer, :restart, :withdraw ], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute status: is { 'proposed' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :refer ], join_by: :and do
      if_permitted_to :chair, :committee
      if_attribute status: is { 'adopted' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :comment ] do
      if_attribute comment_until: gt { Time.zone.now }
    end
    has_permission_on :motion_comments, to: :create do
      if_permitted_to :comment, :motion
    end
    has_permission_on :motion_comments, to: :update, join_by: :and do
      if_permitted_to :comment, :motion
      if_attribute user_id: is { user.id }
    end
    has_permission_on :users, to: :resume do
      if_attribute id: is { user.id }
    end
    has_permission_on :users, to: [ :profile ]
    has_permission_on :users, to: [ :edit, :update, :show, :index ] do
      if_attribute id: is { user.id }
    end
    
    includes :guest
  end
  role :guest do
    has_permission_on :attachments, to: :show do
      if_permitted_to :show, :attachable
      if_attribute attachable_type: 'MotionComment'
    end
    has_permission_on :motions, to: :show do
      if_attribute published: true
    end
    has_permission_on :meetings, to: [ :show, :index ] do
      if_attribute published: is { true }
      if_attribute starts_at: lt { Time.zone.now }
    end
    has_permission_on :user_sessions, to: [ :new, :create ]
    has_permission_on :users, to: [ :register ]
  end
end

privileges do
  privilege :manage do
    includes :create, :update, :destroy
  end
  privilege :reject do
    includes :reactivate, :do_reject
  end
  privilege :create do
    includes :new
  end
  privilege :update do
    includes :edit
  end
  privilege :chair do
    includes :vicechair
  end
end

