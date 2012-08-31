module CommitteeNameLookup
  def committee_name
    committee.name if committee
  end

  def committee_name=(name)
    self.committee = Committee.find_by_name( name )
  end
end

