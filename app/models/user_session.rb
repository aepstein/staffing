class UserSession < Authlogic::Session::Base
  # gettext_activerecord defines a gettext method for the activerecord
  # Validations module. Authlogic uses these Validations also but does
  # not define the gettext method. We define it here instead.
  def gettext(str)
    GetText._(str)
  end

  def to_key
    new_record? ? nil : [ self.send(self.class.primary_key) ]
  end

end

