module Fieldsets
  def have_fieldset(handle)
    have_selector :fieldset, handle
  end
  def have_no_fieldset(handle)
    have_no_selector :fieldset, handle
  end
  def has_fielset?(handle)
    has_selector? :fieldset, handle
  end
  def has_no_fieldset?(handle)
    has_no_selector? :fieldset, handle
  end
end

World(Fieldsets)

