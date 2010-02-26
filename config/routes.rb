ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :positions, :shallow => true do |position|
    position.resources :memberships
    position.resources :requests, :only => [ :new, :create, :index ] do |request|
      request.resources :memberships, :only => [ :new, :create, :index ]
    end
  end
  map.resources :committees, :shallow => true do |committee|
    committee.resources :requests, :only => [ :new, :create, :index ]
    committee.resources :enrollments
    committee.resources :memberships, :only => [ :index ]
  end
  map.resources :requests, :except => [ :new, :create, :index ]
  map.resources :authorities
  map.resources :qualifications
  map.resources :questions, :shallow => true do |question|
    question.resources :answers
  end
  map.resources :schedules, :shallow => true do |schedule|
    schedule.resources :periods
  end
  map.resources :quizzes
  map.resource :user_session, :only => [:create]

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => 'users', :action => 'profile'
end

