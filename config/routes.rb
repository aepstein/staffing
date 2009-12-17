ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :positions, :shallow => true do |position|
    position.resources :memberships
    position.resources :requests do |request|
      request.resources :memberships, :only => [ :new, :create, :index ]
    end
  end
  map.resources :committees, :shallow => true do |committee|
    committee.resources :enrollments
  end
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

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => 'users', :action => 'profile'
end

