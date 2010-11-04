CORNELL_LDAP_CONFIG = YAML.load_file("#{::Rails.root}/config/ldap.yml")[::Rails.env]
CornellLdap::Record.setup_connection CORNELL_LDAP_CONFIG

