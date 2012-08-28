authorization do
  role :admin do
    has_permission_on [ :authorities, :brands, :committees, :enrollments,
      :meetings, :memberships, :motions, :periods, :positions, :qualifications,
      :quizzes, :questions, :requests, :schedules, :users,
      :user_renewal_notices, :sendings ],
      to: [ :manage, :show, :index ]
    has_permission_on :memberships, to: [ :decline_renewal ] do
      if_attribute declined_at: is { nil }, starts_at: lte { Time.zone.today },
        renew_until: is_not { nil }
    end
    has_permission_on :committees, to: [ :tents, :members ]
    has_permission_on :users, to: [ :tent ]
    has_permission_on :users, to: :resume
    has_permission_on :requests, to: [ :reject, :reactivate ]
  end
  role :authority do
    has_permission_on :users, to: :show
  end
  role :user do
    has_permission_on [ :authorities, :brands, :committees, :enrollments,
      :meetings, :memberships, :periods, :positions, :qualifications,
      :schedules ],
      to: [ :show, :index ]
    has_permission_on [ :motions, :requests ], to: :index
    has_permission_on :attachments, to: :show do
      if_permitted_to :show, :attachable
    end
    has_permission_on :committees, to: :vote do
      if_attribute enrollments: {
        position_id: is_in { user.memberships.current.map(&:position_id) },
        votes: gt { 0 } }
    end
    has_permission_on :motions, to: :show, join_by: :and do
      if_attribute status: is { 'started' }
      if_attribute sponsorships: { user_id: is { user.id } }
    end
    has_permission_on :motions, to: :create do
      if_permitted_to :vote, :committee
    end
    has_permission_on :motions, to: [ :manage ], join_by: :and do
      if_permitted_to :vote, :committee
      if_attribute status: is { 'started' },
        sponsorships: { user_id: is { user.id } }
    end
    has_permission_on :users, to: :resume do
      if_attribute id: is { user.id }
    end
    has_permission_on :requests, to: [ :manage, :show ] do
      if_attribute user_id: is { user.id }
    end
    has_permission_on :requests, to: [ :show ] do
      if_attribute committee_id: is_in { user.committees.authorized(0).map(&:id) }
    end
    has_permission_on :requests, to: [ :reject ] do
      if_attribute committee_id: is_in { user.committees.authorized.map(&:id) }
    end
    has_permission_on :memberships, to: [ :manage ] do
      if_attribute position: { authority: { authorized_enrollments: {
        votes: gt { 0 },
        memberships: {
        user_id: is { user.id },
        starts_at: lte { object.blank? ? Time.zone.today : object.ends_at },
        ends_at: gte { object.blank? ? Time.zone.today : [ object.starts_at, Time.zone.today ].max }
      } } } }
    end
    has_permission_on :memberships, to: [ :decline_renewal ], join_by: :and do
      if_attribute declined_at: is { nil }, starts_at: lte { Time.zone.today },
        renew_until: is_not { nil }
      if_attribute position: { authority: { authorized_enrollments: {
        votes: gt { 0 },
        memberships: {
        user_id: is { user.id },
        ends_at: gte { object.blank? ? Time.zone.today : [ object.ends_at, Time.zone.today ].max }
      } } } }
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
  privilege :decline_renewal do
    includes :do_decline_renewal
  end
end

