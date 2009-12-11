ActionController::Routing::Routes.draw do |map|
  map.resources :users, :shallow => true do |user|
    user.resources :memberships
  end
  map.resources :positions do |position|
    position.resources :enrollments
    position.resources :requests
  end
  map.resources :committees
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

