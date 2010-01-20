authorization do
  role :admin do
    has_permission_on [ :authorities, :committees, :enrollments, :memberships,
      :periods, :positions, :qualifications, :quizzes, :questions, :requests,
      :schedules, :users ], :to => :manage
  end
  role :user do
    has_permission_on [ :authorities, :committees, :enrollments, :memberships,
      :periods, :positions, :qualifications, :schedules ],
      :to => [:show, :index]
    has_permission_on :requests, :to => :manage do
      if_attribute :user_id => is { user.id }, :state => is { 'started' }
    end
    has_permission_on :requests, :to => [ :new, :create ]
    has_permission_on :requests, :to => [:show, :index] do
      if_attribute :user_id => is { user.id }
    end
  end
  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
  end
end

privileges do
  privilege :manage do
    includes :create, :new, :update, :edit, :destroy, :show, :index
  end
end

