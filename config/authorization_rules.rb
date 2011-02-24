authorization do
  role :admin do
    has_permission_on [ :authorities, :committees, :enrollments, :meetings,
      :memberships, :motions, :periods, :positions, :qualifications, :quizzes,
      :questions, :requests, :schedules, :users, :user_renewal_notices,
      :sendings ],
      :to => :manage
    has_permission_on :users, :to => :resume
    has_permission_on :requests, :to => [ :reject, :unreject ]
  end
  role :user do
    has_permission_on [ :authorities, :committees, :enrollments, :meetings,
      :memberships, :periods, :positions, :qualifications, :schedules ],
      :to => [:show, :index]
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
    has_permission_on :motions, :to => :manage, :join_by => :and do
      if_permitted_to :vote, :committee
      if_attribute :status => is { 'started' }, :sponsorships => { :user_id => is { user.id } }
    end
    has_permission_on :users, :to => :resume do
      if_attribute :id => is { user.id }
    end
    has_permission_on :requests, :to => :manage do
      if_attribute :user_id => is { user.id }
    end
    has_permission_on :requests, :to => [ :show, :reject ] do
      if_attribute :requestable_type => is { 'Position' }, :requestable_id => is_in { user.authorized_position_ids }
      if_attribute :requestable_type => is { 'Committee' }, :requestable_id => is_in { user.authorized_committee_ids }
    end
    has_permission_on :memberships, :to => [ :manage ] do
      if_attribute :position_id => is_in { user.authorized_position_ids }
    end
    has_permission_on :users, :to => [ :show ] do
      if_permitted_to :show, :requests
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
    includes :create, :update, :destroy, :show, :index
  end
  privilege :reject do
    includes :unreject, :do_reject
  end
  privilege :vote do
    includes :show
  end
  privilege :create do
    includes :new
  end
  privilege :update do
    includes :edit
  end
end

