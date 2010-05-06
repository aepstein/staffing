module MembershipsHelper
  def link_to_renewal( membership )
    link_to_if (membership.position.renewable? && membership.position.requestables.size > 0),
      'Renew',
      ( membership.request ? edit_request_path(membership.request) : new_membership_request_path(membership) )
  end
end

