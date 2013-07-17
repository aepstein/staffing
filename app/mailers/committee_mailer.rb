class CommitteeMailer < ActionMailer::Base
  attr_accessor :committee
  helper_method :vicechairs, :committee
  helper CommitteesHelper

  def must_meet_notice( committee, options = {})
    self.committee = committee
    mail( to: vicechairs.map(&:to_email),
      from: committee.effective_contact_name_and_email,
      subject: "#{committee} must meet" )
  end

  def clerks
    @clerks ||= committee.users_for(:clerks)
  end

  def vicechairs
    @vicechairs ||= committee.users_for(:vicechairs)
  end
end

