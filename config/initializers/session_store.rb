# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_staffing_session',
  :secret      => '04ce0730a52b37fd3384bba118a7c1546aedc235499d2560c5eeca1c7ebbb0a25c8a75389a31ab26b50c4394e6a92c9706f4bd224ffa3dd0f7755ac887ddb492'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
