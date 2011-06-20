authorization do
  role :admin do
    has_permission_on [ :authorities, :committees, :enrollments, :meetings,
      :memberships, :motions, :periods, :positions, :qualifications, :quizzes,
      :questions, :requests, :schedules, :users, :user_renewal_notices,
      :sendings ],
      :to => [ :manage, :show, :index ]
    has_permission_on :committees, :to => [ :tents, :members ]
    has_permission_on :users, :to => [ :tent ]
    has_permission_on :users, :to => :resume
    has_permission_on :requests, :to => [ :reject, :reactivate ]
  end
  role :authority do
    has_permission_on :users, :to => :show
  end
  role :user do
    has_permission_on [ :authorities, :committees, :enrollments, :meetings,
      :memberships, :periods, :positions, :qualifications, :schedules ],
      :to => [ :show, :index ]
    has_permission_on [ :motions, :requests ], :to => :index
    has_permission_on :committees, :to => :vote do
      if_attribute :enrollments => { :position_id => is_in { user.memberships.current.map(&:position_id) }, :votes => gt { 0 } }
    end
    has_permission_on :motions, :to => :show, :join_by => :and do
      if_attribute :status => is { 'started' }
      if_attribute :sponsorships => { :user_id => is { user.id } }
    end
    has_permission_on :motions, :to => :create do
      if_permitted_to :vote, :committee
    end
    has_permission_on :motions, :to => [ :manage ], :join_by => :and do
      if_permitted_to :vote, :committee
      if_attribute :status => is { 'started' }, :sponsorships => { :user_id => is { user.id } }
    end
    has_permission_on :users, :to => :resume do
      if_attribute :id => is { user.id }
    end
    has_permission_on :requests, :to => [ :manage, :show ] do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on :requests, :to => [ :show, :reject ] do
      if_attribute :requestable_type => is { 'Position' }, :requestable_id => is_in { user.authorized_position_ids }
      if_attribute :requestable_type => is { 'Committee' }, :requestable_id => is_in { user.authorized_committee_ids }
    end
    has_permission_on :memberships, :to => [ :manage ] do
#      if_attribute :position_id => is_in { user.authorized_position_ids }
      # Note: This only works when applied to a specific membership object, not
      # adequate for obligation_scope
      if_attribute :position => { :authority => { :authorized_enrollments => { :memberships => {
        :user_id => is { user.id },
        :starts_at => lte { object.blank? ? Time.zone.today : object.ends_at },
        :ends_at => gte { object.blank? ? Time.zone.today : [ object.starts_at, Time.zone.today ].max }
      } } } }
    end
    has_permission_on :users, :to => [ :profile ]
    has_permission_on :users, :to => [ :edit, :update, :show, :index ] do
      if_attribute :id => is { user.id }
    end
  end
  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
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
end

