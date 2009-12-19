authorization do
  role :admin do
    has_permission_on [ :authorities, :commitees, :enrollments, :memberships,
      :periods, :positions, :qualifications, :quizzes, :requests, :schedules,
      :users ]
  end
  role :user do
    has_permission_on :requests, :to => :manage do
      if_attribute :user_id is { user.id }
    end
  end
  role :guest do
    has_permission_on :user_sessions, :to => [ :new, :create ]
  end
end

privileges do
  privilege :manage do
    includes :create, :read, :update, :delete
  end
end

