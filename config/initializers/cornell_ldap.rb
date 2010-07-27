CORNELL_LDAP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/ldap.yml")[RAILS_ENV]
CornellLdap::Record.setup_connection CORNELL_LDAP_CONFIG

