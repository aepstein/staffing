authorization do
  role :admin do
    has_permission_on [ :authorities, :committees, :enrollments, :memberships,
      :periods, :positions, :qualifications, :quizzes, :requests, :schedules,
      :users ], :to => :manage
  end
  role :user do
    has_permission_on [ :authorities, :committees, :enrollments, :memberships ],
      :to => [:show, :index]
    has_permission_on :requests, :to => :manage do
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

