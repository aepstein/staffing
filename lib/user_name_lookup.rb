module UserNameLookup
  def user_name
    "#{user.name} (#{user.net_id})" if user
  end

  def user_name=(name)
    if name.to_net_ids.empty?
      self.user = User.where( net_id: name[/\(([^\s]*)\)/,1] ).first
    else
      self.user = User.find_or_create_by( net_id: name.to_net_ids.first )
    end
    self.user = nil if user && user.id.nil?
  end
end

