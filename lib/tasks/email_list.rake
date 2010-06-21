task :email_list => [ 'email_list:build', 'email_list:clean' ]

namespace :email_list do
  desc "Build all email lists"
  task :build => 'build:all'

  desc "Remove all obsolete email lists"
  task :clean => 'clean:all'

  namespace :build do

    desc "Build or update all email lists"
    task :all => [ :committees, :positions ]

    desc "Build or update email list for each committee"
    task :committees => [ :environment ] do
      Committee.all.each do |committee|
        file = open_email_list_file( current_committees_root, committee )
        write_emails_to_file file, committee.current_emails
        file.close
      end
    end

    desc "Build or update email list for each position"
    task :positions => [ :environment ] do
      Position.all.each do |position|
        file = open_email_list_file( current_positions_root, position )
        write_emails_to_file file, position.current_emails
        file.close
      end
    end

  end

  namespace :clean do

    desc "Remove all obsolete email lists"
    task :all => [ :committees, :positions ]

    desc "Remove email list for each committee that has been renamed or destroyed"
    task :committees => [ :environment ] do
      root = current_committees_root
      FileUtils.mkdir_p(root)
      FileUtils.rm( Dir.glob( "#{root}/*" ) - email_list_files(root, Committee.all) )
    end

    desc "Remove email list for each position that has been renamed or destroyed"
    task :positions => [ :environment ] do
      root = current_positions_root
      FileUtils.mkdir_p(root)
      FileUtils.rm( Dir.glob( "#{root}/*" ) - email_list_files(root, Position.all) )
    end

  end

  def current_committees_root
      root = "#{current_email_lists_path}/committees"
      FileUtils.mkdir_p(root)
      root
  end

  def current_positions_root
      root = "#{current_email_lists_path}/positions"
      FileUtils.mkdir_p(root)
      root
  end

  def email_list_files( path, subjects )
    subjects.map { |subject| "#{path}/#{subject.name :file}" }
  end

  def current_email_lists_path
    "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/email_lists/current"
  end

  def open_email_list_file(path, subject)
    File.open( "#{path}/#{subject.name :file}", 'w' )
  end

  def write_emails_to_file( file, emails )
    emails.each { |email| file << "#{email}\n" }
    file
  end

end

