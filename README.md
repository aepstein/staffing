=Shared Governance Systemm

This is an online platform to support the operations of shared campus governance
at Cornell University.  This encompasses work cycle related to staffing
shared governance assemblies, committees, and related positions.  It also
covers tracking of shared governance meetings, meeting inputs, and outputs.

==Key Files

This application utilizes default Rails best practices as much as possible.
See the config directory for key settings:
* config/deploy.rb: Deployment to production using capistrano
* config/authorization_rules.rb: Role-based access control using
  declarative_authorization
* config/schedule.rb: Scheduled tasks via CRON using whenever gem.
* config/ldap.yml: LDAP configuration utilized by cornell_ldap gem to query
  Cornell University enterprise LDAP for information about users such as their
  affiliation status with the university.

==Specialized gem dependencies

* cornell\_assemblies\_rails: Provides common functionality that can be
  factored out of multiple assemblies rails applications, especially UI
  features and building blocks like bootstrap, widgets, SSO authentication
* cornell-assemblies-branding: Provides assemblies-specific branding for
  unique look and feel of Assemblies websites
* cornell_ldap: Used to query Cornell Directory
* cornell_netid: Used to parse Cornell-style netids
* blind_date: Used to perform date comparisons associated with committee schedules.

==Features and Philosophy

The intent of this application is to support the operations of campus assemblies
in a way that enables individuals to record and query information about committee
membership and activities accurately and easily, while also assuring the information
is available to assemblies staff and other stakeholders to provide support
and disseminate on all appropriate channels.

The committee staffing component has the following basic features:
* Any logical grouping of people, including campus assemblies, their committees, and
  other formally designated groups are represented as _committees_.
* _Positions_ denote specific roles within committees.  Users are appointed to 
  positions through _memberships_ for fixed terms with start and end dates.
  Positions can be connected with _authorities_, which specify a committee
  authorized to staff the position, and a _schedule_ on which membership in the 
  position is to turn over.
* _Enrollments_ map positions to specific roles and privileges in committees.
* _Schedules_ may contain one or more _periods_ that specify when a class of appointees
  to the position are to start and end by default.
* The system can automatically create vacant memberships according to schedules for
  each position to map out for _authority_ committee members what slots they must fill.
* The system generates notices on appointment, starting, and terminating membership.
* The system generates renewal notices and provides a framework for renewing memberships.
* The system permits users to apply for membership on committees where they are eligible
  to be appointed to one or more _requestable_ position.  The _quizzes_ associated with such
  positions determine the questions they are asked in their _membership\_request_.
* Each _committee_ can be associated with a _brand_, allowing custom imagery and contact
  information on associated PDF reports.
* Reports include: tent cards for committee members or individual users, membership
  directories, and a variety of CSV dumps.
* Current and upcoming membership information for each committee is dumped nightly
  into flat text files that Sympa mailing lists can use to update their subscriptions
  from.  Users are thus automatically added and removed each day based on the parameters
  of their membership.

The meetings component, which was added later, encompasses additional functionality:
* Users with _vicechair_ privileges on committees can create _meetings_.
* Committees can have a _meeting\_template_ that establishes the proper default
  layout of meeting agendas.
* Committee members can also propose _motions_, which can be associated with meetings.
* The meeting, the associated agenda, and all attachments can be compiled into an email
  through _publish_ feature.  This permits the chair or vicechair to send out a consistent,
  complete, and organized agenda for each meeting with minimal difficulty.  The committee
  can have a default publication email address that points to a mailing list where
  committee business announcements are expected to be sent.
* Each _motion_ can be tracked with a stated-based workflow engine that allows tracking
  and reporting of motion status.
* Published meetings are streamed in a CSV format that the institution's calendaring
  software uses to provide meeting information to the broader community.

==Tests and Documentation

The application has two primary sources of tests and documentation:
* features/*.feature: Contains plain-English cucumber features covering the range of features
  provided by the software.
* spec/models: Unit tests of models
* spec/mailers: Acceptance tests of mailers

