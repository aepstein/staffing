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
  resources :committees do
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
    resources :motions, :only => [ :index, :new, :create ]
    resources :positions, :only => [ :index ]
    resources :requests, :only => [ :new, :create, :index ] do
      collection do
        get :expired, :unexpired, :active, :rejected
      end
    end
  end
  resources :enrollments, :except => [ :index, :new, :create ]
  resources :meetings, :except => [ :new, :create ] do
    collection do
      get :past, :current, :future
    end
  end
  resources :memberships, :except => [ :index, :new, :create ] do
    member do
      put :confirm
    end
    resources :requests, :only => [ :new, :create ]
  end
  resources :motions, :except => [ :index, :new, :create ]
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
      put :do_reject, :unreject
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
      get :resume
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
        get :current, :future, :past, :unrenewed, :renewed
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
    resources :sendings, :only => [ :index ]
  end
  resources :user_renewal_notices do
    resources :sendings, :only => [ :index, :show, :destroy ]
  end
  resource :user_session, :only => [:create]

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'profile', :to => 'users#profile', :as => 'profile'

  root :to => 'users#profile'
end

