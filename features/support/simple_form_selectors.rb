module SimpleFormSelectors
  def within_control_group(content, &block)
    within :xpath, control_group(content), &block
  end
  def control_group(content)
    XPath.descendant(:*)[ XPath.attr(:class).contains( "control-group" ) &
      XPath.child(:label)[XPath.string.n.equals(content)] ]
  end
end

Spork.each_run do
  World(SimpleFormSelectors)
end
