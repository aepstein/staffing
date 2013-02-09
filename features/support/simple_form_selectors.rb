Spork.each_run do
  Capybara.add_selector(:control_group) do
    xpath do |content|
      XPath.descendant(:*)[ XPath.attr(:class).contains( "control-group" ) &
      XPath.child(:label)[XPath.string.n.equals(content)] ]
    end
  end

  Capybara.add_selector(:control_group_containing) do
    xpath do |content|
      XPath.descendant(:*)[ XPath.attr(:class).contains( "control-group" ) &
      XPath.child(:label)[XPath.string.n.contains(content)] ]
    end
  end

  module SimpleFormSelectors
    def within_control_group(content, &block)
      within :control_group, content, &block
    end
    def within_control_group_containing(content, &block)
      within :control_group_containing, content, &block
    end
    def have_control_group(handle)
      have_selector :control_group, handle
    end
    def have_no_control_group(handle)
      have_no_selector :control_group, handle
    end
    def has_control_group?(handle)
      has_selector? :control_group, handle
    end
    def has_no_control_group?(handle)
      has_no_selector? :control_group, handle
    end
  end

  World(SimpleFormSelectors)
end

