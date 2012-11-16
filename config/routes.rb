Staffing::Application.routes.draw do
  resources :answers, except: [ :index, :new, :create ]
  resources :attachments, only: [ :show ]
  resources :authorities do
    resources :memberships, only: [ :index ] do
      collection do
        get :current, :future, :past, :renewable
      end
    end
    resources :membership_requests, only: [ :index ] do
      collection do
        get :expired, :unexpired, :active, :inactive, :rejected
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
      get :tents, :members, :empl_ids
    end
    collection do
      get :available
    end
    resources :meetings, only: [ :index, :new, :create ] do
      collection do
        get :past, :current, :future
      end
    end
    resources :memberships, only: [ :index ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed
      end
    end
    resources :motions, only: [ :index, :new, :create ] do
      collection do
        get :past, :current, :proposed
      end
    end
    resources :positions, only: [ :index ]
    resources :membership_requests, only: [ :new, :create, :index ] do
      collection do
        get :expired, :unexpired, :active, :inactive, :rejected
      end
    end
  end
  resources :meetings, except: [ :new, :create ] do
    member do
      get :editable_minutes, :published_minutes, :audio
    end
    collection do
      get :past, :current, :future
    end
    resources :motions, only: [ :index ] do
      collection do
        get :allowed
      end
    end
  end
  resources :memberships, except: [ :index, :new, :create ] do
    member do
      get :decline
      put :decline
    end
  end
  resources :membership_requests, except: [ :index, :new, :create ] do
    member do
      get :reject
      put :reject, :reactivate
    end
    resources :memberships, only: [ :index ] do
      collection do
        get :assignable
      end
    end
  end
  resources :motions, except: [ :new, :create ] do
    member do
      get :divide, :merge, :refer
      put :adopt, :divide, :implement, :merge, :propose, :refer, :reject,
        :restart, :withdraw
    end
    resources :users, only: [ :index ] do
      collection do
        get :allowed
      end
    end
    resources :meetings, only: [ :index ] do
      collection do
        get :past, :current, :future
      end
    end
  end
  resources :positions do
    resources :memberships, only: [ :index, :new, :create ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed
      end
    end
    resources :membership_requests, only: [ :new, :create, :index ] do
      collection do
        get :expired, :unexpired, :active, :inactive, :rejected
      end
    end
  end
  resources :qualifications
  resources :questions do
    resources :answers, only: [ :index, :new, :create ]
  end
  resources :quizzes do
    resources :questions, only: [ :index ]
  end
  resources :schedules
  resources :users do
    member do
      get :resume, :tent
    end
    collection do
      get :import_empl_id
      put :do_import_empl_id
    end
    resources :committees, only: [] do
      collection do
        get :requestable
      end
    end
    resources :enrollments, only: [ :index ] do
      collection do
        get :current, :future, :past
      end
    end
    resources :memberships, only: [ :index ] do
      collection do
        get :current, :future, :past, :unrenewed, :renewed, :renew
        put :renew
      end
    end
    resources :motions, only: [ :index ] do
      collection do
        get :current, :past, :proposed
      end
    end
    resources :positions, only: [:index] do
      collection do
        get :requestable
      end
    end
    resources :membership_requests, only: [ :index, :new, :create ] do
      collection do
        get :expired, :unexpired, :rejected, :active, :inactive
      end
    end
  end
  resource :user_session, only: [:create]

  match 'login', to: 'user_sessions#new', as: 'login'
  match 'logout', to: 'user_sessions#destroy', as: 'logout'
  match 'profile', to: 'users#profile', as: 'profile'

  root to: 'users#profile'
end

