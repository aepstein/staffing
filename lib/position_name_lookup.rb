module PositionNameLookup
  def position_name
    position.name if position
  end

  def position_name=(name)
    self.position = Position.find_by_name( name )
  end
end

