Staffing::Application.configure do
  config.cache_classes = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.serve_static_assets = false
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.assets.js_compressor  = :uglifier
#  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  config.filter_parameters += [ :password, :password_confirmation ]
  config.assets.precompile += %w( ie6.css ie7.css print.css )
  config.threadsafe! unless ENV['THREADSAFE'] == 'off'
  config.middleware.use ExceptionNotification::Rack, email: {
    email_prefix: "[staffing] ",
    sender_address: %{"Assemblies IT Support" <assembly-it@cornell.edu>},
    exception_recipients: %w{assembly-it@cornell.edu}
  }
  config.eager_load = true
end

