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
  resources :meeting_templates
  resources :meetings, except: [ :new, :create ] do
    member do
      get :editable_minutes, :published_minutes, :audio, :agenda, :publish
      put :publish
    end
    collection do
      get :past, :current, :future
    end
    resources :motions, only: [ :index, :new, :create ] do
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
      get :adopt, :amend, :divide, :implement, :merge, :propose, :refer,
        :reject, :withdraw
      put :adopt, :amend, :divide, :implement, :merge, :propose, :refer,
        :reject, :restart, :unwatch, :watch, :withdraw
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
    resources :motion_comments, only: [ :new, :create, :index ]
  end
  resources :motion_comments, except: [ :new, :create, :index ]
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
  resources :questions
  resources :quizzes do
    resources :questions, only: [ :index ]
  end
  namespace :public, as: :public do
    resources :meetings, only: [ :index ]
    resources :committees, only: [] do
      resources :meetings, only: [ :index ]
      resources :motions, only: [ :index ]
    end
    resources :motions, only: [ :index ]
  end
  namespace :review, as: :reviewable do
    resources :memberships, only: [] do
      collection do
        get :assigned, :unassigned, :renewable, :declined
      end
    end
    resources :membership_requests, only: [] do
      collection do
        get :active, :inactive
      end
    end
  end
  resources :schedules
  resources :users do
    member do
      get :resume, :tent
    end
    collection do
      get :admin, :import_empl_id, :staff
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
    resources :meetings, only: [ :index ]
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
  
  get '/sso/:provider/login', to: 'user_sessions#sso_login', as: 'sso_login',
    constraints: SsoProviderConstraint.new
  match '/sso/:provider/register', to: 'users#register', as: 'sso_register',
    via: [ :get, :post ], constraints: SsoProviderConstraint.new

  get 'login', to: 'user_sessions#new', as: 'login'
  get 'logout', to: 'user_sessions#destroy', as: 'logout'
  get 'home', to: 'home#home', as: 'home'

  root to: 'home#home'
end

