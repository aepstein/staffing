ActionController::Routing::Routes.draw do |map|
  map.resources :user_renewal_notices, :shallow => true do |notice|
    notice.resources :sendings, :only => [ :index, :show, :destroy ]
  end
  map.resources :memberships, :only => [], :member => { :confirm => :put }
  map.resources :users, :shallow => true, :member => { :resume => :get } do |user|
    user.resources :sendings, :only => [ :index ]
    user.resources :requests, :collection => { :expired => :get, :unexpired => :get }
    user.resources :committees, :only => [], :collection => { :requestable => :get }
    user.resources :enrollments, :only => [:index], :collection => { :current => :get, :future => :get, :past => :get }
    user.resources :positions, :only => [], :collection => { :requestable => :get }
    user.resources :memberships, :only => [:index],
      :collection => { :current => :get, :future => :get, :past => :get, :unrenewed => :get, :renewed => :get }
  end
  map.resources :positions, :shallow => true do |position|
    position.resources :memberships, :collection => { :current => :get,
      :future => :get, :past => :get, :unrenewed => :get, :renewed => :get } do |membership|
      membership.resources :requests, :only => [ :new, :create ]
    end
    position.resources :requests, :only => [ :new, :create, :index ], :collection => { :expired => :get, :unexpired => :get } do |request|
      request.resources :memberships, :only => [ :new, :create, :index ]
    end
  end
  map.resources :committees, :shallow => true, :collection => { :available => :get } do |committee|
    committee.resources :requests, :only => [ :new, :create, :index ], :collection => { :expired => :get, :unexpired => :get }
    committee.resources :enrollments
    committee.resources :positions, :only => [ :index ]
    committee.resources :memberships, :only => [ :index ],
      :collection => { :current => :get, :future => :get, :past => :get, :unrenewed => :get, :renewed => :get }
  end
  map.resources :authorities, :shallow => true do |authority|
    authority.resources :memberships, :only => [ :index ], :collection => { :current => :get, :future => :get, :past => :get }
    authority.resources :requests, :only => [ :index ], :collection => { :expired => :get, :unexpired => :get }
  end
  map.resources :qualifications
  map.resources :questions, :shallow => true do |question|
    question.resources :answers
  end
  map.resources :schedules, :shallow => true do |schedule|
    schedule.resources :periods
  end
  map.resources :quizzes, :shallow => true do |quiz|
    quiz.resources :questions, :only => [ :index ]
  end
  map.resource :user_session, :only => [:create]

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.profile 'profile', :controller => 'users', :action => 'profile'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.root :controller => 'users', :action => 'profile'
end

