Staffing::Application.routes.draw do
  shallow do
    resources :user_renewal_notices do
      resources :sendings, :only => [ :index, :show, :destroy ]
    end
    resources :memberships, :only => [] do
      member do
        put :confirm
      end
    end
    resources :users do
      member do
        get :resume
      end
      resources :sendings, :only => [ :index ]
      resources :requests do
        collection do
          get :expired, :unexpired, :rejected, :active
        end
        member do
          get :reject
          put :do_reject, :unreject
        end
      end
      resources :committees, :only => [] do
        collection do
          get :requestable
        end
      end
      resources :enrollments, :only => [:index] do
        collection do
          get :current, :future, :past
        end
      end
      resources :positions, :only => [] do
        collection do
          get :requestable
        end
      end
      resources :memberships, :only => [:index] do
        collection do
          get :current, :future, :past, :unrenewed, :renewed
        end
      end
    end
    resources :positions do
      resources :memberships do
        collection do
          get :current, :future, :past, :unrenewed, :renewed
        end
        resources :requests, :only => [ :new, :create ]
      end
      resources :requests, :only => [ :new, :create, :index ] do
        collection do
          get :expired, :unexpired, :active, :rejected
        end
        resources :memberships, :only => [ :new, :create, :index ] do
          collection do
            get :assignable
          end
        end
      end
    end
    resources :committees do
      collection do
        get :available
      end
      resources :motions
      resources :requests, :only => [ :new, :create, :index ] do
        collection do
          get :expired, :unexpired, :active, :rejected
        end
      end
      resources :enrollments
      resources :positions, :only => [ :index ]
      resources :memberships, :only => [ :index ] do
        collection do
          get :current, :future, :past, :unrenewed, :renewed
        end
      end
    end
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
    resources :qualifications
    resources :questions do
      resources :answers
    end
    resources :schedules do
      resources :periods
    end
    resources :quizzes do
      resources :questions, :only => [ :index ]
    end
    resource :user_session, :only => [:create]
  end

  match 'login', :to => 'user_sessions#new', :as => 'login'
  match 'logout', :to => 'user_sessions#destroy', :as => 'logout'
  match 'profile', :to => 'users#profile', :as => 'profile'

  root :to => 'users#profile'
end

