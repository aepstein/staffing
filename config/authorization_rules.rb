authorization do
  role :admin do
    has_permission_on [ :authorities, :brands, :committees,
      :meetings, :memberships, :motions, :positions,
      :quizzes, :questions, :membership_requests, :schedules, :users,
      :user_renewal_notices, :sendings ],
      to: [ :manage ]

    includes :staff
  end
  role :staff do
    has_permission_on [ :authorities, :brands, :committees,
      :meetings, :memberships, :motions, :positions,
      :quizzes, :questions, :membership_requests, :schedules, :users,
      :user_renewal_notices, :sendings ],
      to: [ :create, :update, :show, :index, :staff ]
    has_permission_on :committees, to: [ :chair, :members, :tents, :vote ]
    has_permission_on :memberships, to: [ :decline ] do
      if_attribute declined_at: is { nil }, starts_at: lte { Time.zone.today },
        renew_until: is_not { nil }, position: { renewable: true }
    end
    has_permission_on :motions, to: [ :admin, :adopt, :divide, :implement,
      :merge, :propose, :refer, :reject, :restart, :withdraw ]
    has_permission_on :users, to: [ :resume, :staff, :tent ]
    has_permission_on :membership_requests, to: [ :reject, :reactivate ]

    includes :user
  end
  role :authority do
    has_permission_on :users, to: :show
  end
  role :user do
    has_permission_on [ :authorities, :brands, :committees, :memberships,
      :positions, :schedules ],
      to: [ :show, :index ]
    has_permission_on [ :motions, :membership_requests ], to: :index
    has_permission_on :attachments, to: :show do
      if_permitted_to :show, :attachable
    end
    has_permission_on :committees, to: :vote do
      if_attribute enrollments: {
        position_id: is_in { user.memberships.current.map(&:position_id) },
        votes: gt { 0 } }
    end
    has_permission_on :committees, to: :chair do
      if_attribute enrollments: {
        manager: is { true },
        position_id: is_in { user.memberships.current.map(&:position_id) },
        votes: gt { 0 } }
    end
    has_permission_on :meetings, to: :show do
      if_attribute published: is { true }
      if_attribute ends_at: lt { Time.zone.now }
      if_attribute committee: { enrollments: { position_id: is_in { user.memberships.
        where { ends_at.gte( Time.zone.today ) }.map(&:position_id) } } }
    end
    has_permission_on :meetings, to: :manage, join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute period: { starts_at: lte { Time.zone.today },
        ends_at: gte { Time.zone.today } }
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
        renew_until: is_not { nil }, position: { renewable: true,
        authority: { authorized_enrollments: {
        votes: gt { 0 },
        memberships: {
        user_id: is { user.id },
        starts_at: lte { object.renew_until },
        ends_at: gt { [ object.ends_at, ( Time.zone.today - 1.day ) ].max },
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
      if_permitted_to :vote, :committee
    end
    has_permission_on :motions, to: :update, join_by: :and do
      if_permitted_to :own
      if_attribute status: is { 'started' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: :show do
      if_attribute published: true
      if_attribute sponsorships: { user_id: is { user.id } }
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
    has_permission_on :motions, to: [ :adopt, :divide, :merge, :refer, :reject,
      :restart, :withdraw ], join_by: :and do
      if_permitted_to :vicechair, :committee
      if_attribute status: is { 'proposed' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :motions, to: [ :refer ], join_by: :and do
      if_permitted_to :chair, :committee
      if_attribute status: is { 'adopted' },
        period: { starts_at: lte { Time.zone.today }, ends_at: gte { Time.zone.today } }
    end
    has_permission_on :users, to: :resume do
      if_attribute id: is { user.id }
    end
    has_permission_on :users, to: [ :profile ]
    has_permission_on :users, to: [ :edit, :update, :show, :index ] do
      if_attribute id: is { user.id }
    end
  end
  role :guest do
    has_permission_on :user_sessions, to: [ :new, :create ]
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

