class SsoProviderConstraint
  attr_accessor :providers
  def initialize
    self.providers = Staffing::Application.sso_providers
  end
  
  def matches?(request)
    providers.map { |p| p['path'] == request.request_parameters['provider'] }
  end
end
