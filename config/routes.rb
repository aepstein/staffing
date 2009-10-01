ActionController::Routing::Routes.draw do |map|
  map.resources :users do |user|
    user.resources :memberships
  end
  map.resources :committees, :shallow => true do |committee|
    committee.resources :positions do |position|
      position.resources :enrollments
      position.resources :requests
    end
  end
  map.resources :authorities
  map.resources :qualifications
  map.resources :questions do |question|
    question.resources :answers
  end
  map.resources :schedules, :shallow => true do |schedule|
    schedule.resources :terms
  end
  map.resources :quizzes

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

