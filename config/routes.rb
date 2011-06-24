Staffing::Application.routes.draw do
  resources :answers, :except => [ :index, :new, :create ]
  resources :authorities do
    resources :memberships, :only => [ :index ] do
      collection do
        get :current, :future, :past
      end
    end
    resources :requests, :only => [ :index ] do
      collection do
        get :expired, :unexpired, :active, :rejected
      end
    end
  end
  resources :brands do
    member do
      get :thumb
    end
  end
  resources :committees do
    member do
      get :tents, :members
    end
    collection do
      get :available
    end
    resources :enrollments, :only => [ :index, :new, :create ]
    resources :meetings, :only => [ :index, :new, :create ] do
      collection do
        get :past, :current, :future
      end
    end
    resources :memberships, :only => [ :index ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed
      end
    end
    resources :motions, :only => [ :index, :new, :create ] do
      collection do
        get :past, :current
      end
    end
    resources :positions, :only => [ :index ]
    resources :requests, :only => [ :new, :create, :index ] do
      collection do
        get :expired, :unexpired, :active, :rejected
      end
    end
  end
  resources :enrollments, :except => [ :index, :new, :create ]
  resources :meetings, :except => [ :new, :create ] do
    member do
      get :editable_minutes, :published_minutes, :audio
    end
    collection do
      get :past, :current, :future
    end
    resources :motions, :only => [ :index ] do
      collection do
        get :allowed
      end
    end
  end
  resources :memberships, :except => [ :index, :new, :create ]
  resources :motions, :except => [ :new, :create ] do
    resources :users, :only => [ :index ] do
      collection do
        get :allowed
      end
    end
    resources :meetings, :only => [ :index ] do
      collection do
        get :past, :current, :future
      end
    end
  end
  resources :periods, :except => [ :index, :new, :create ]
  resources :positions do
    resources :memberships, :only => [ :index, :new, :create ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed
      end
    end
    resources :requests, :only => [ :new, :create, :index ] do
      collection do
        get :expired, :unexpired, :active, :rejected
      end
    end
  end
  resources :qualifications
  resources :questions do
    resources :answers, :only => [ :index, :new, :create ]
  end
  resources :quizzes do
    resources :questions, :only => [ :index ]
  end
  resources :requests, :except => [ :index, :new, :create ] do
    member do
      get :reject
      put :do_reject, :reactivate
    end
    resources :memberships, :only => [ :new, :create, :index ] do
      collection do
        get :assignable
      end
    end
  end
  resources :schedules do
    resources :periods, :only => [ :index, :new, :create ]
  end
  resources :users do
    member do
      get :resume, :tent
    end
    resources :committees, :only => [] do
      collection do
        get :requestable
      end
    end
    resources :enrollments, :only => [ :index ] do
      collection do
        get :current, :future, :past
      end
    end
    resources :memberships, :only => [ :index ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed, :renew
        put :renew
      end
    end
    resources :positions, :only => [] do
      collection do
        get :requestable
      end
    end
    resources :requests, :only => [ :index, :new, :create ] do
      collection do
        get :expired, :unexpired, :rejected, :active
      end
    end
  end
  resource :user_session, :only => [:create]

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'profile', :to => 'users#profile', :as => 'profile'

  root :to => 'users#profile'
end

