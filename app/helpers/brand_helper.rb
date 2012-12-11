module BrandHelper
  def will_override_default_contact( attribute )
    default = Staffing::Application.app_config['defaults']['contact'][attribute.to_s]
    "This will override the default value " +
    (default.blank? ? "which is blank" : "of #{default}") + "."
  end
end

