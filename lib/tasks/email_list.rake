task :email_list => [ 'email_list:build', 'email_list:clean' ]

namespace :email_list do
  desc "Build all email lists"
  task build: 'build:all'

  desc "Remove all obsolete email lists"
  task clean: 'clean:all'

  namespace :build do

    desc "Build or update all email lists"
    task all: [ :committees, :positions ]

    desc "Build or update email list for each committee"
    task committees: [ :environment ] do
      Committee.all.each do |committee|
        %w( current upcoming ).each do |group|
          file = open_email_list_file( email_lists_root( group, 'committees' ), committee )
          write_emails_to_file file, committee.emails( group )
          file.close
        end
      end
    end

    desc "Build or update email list for each position"
    task positions: [ :environment ] do
      Position.all.each do |position|
        %w( current upcoming ).each do |group|
          file = open_email_list_file( email_lists_root( group, 'positions' ), position )
          write_emails_to_file file, position.emails( group )
          file.close
        end
      end
    end

  end

  namespace :clean do

    desc "Remove all obsolete email lists"
    task all: [ :committees, :positions ]

    desc "Remove email list for each committee that has been renamed or destroyed"
    task committees: [ :environment ] do
      %w( current upcoming ).each do |group|
        root = email_lists_root( group, 'committees' )
        FileUtils.mkdir_p(root)
        FileUtils.rm( Dir.glob( "#{root}/*" ) - email_list_files(root, Committee.all) )
      end
    end

    desc "Remove email list for each position that has been renamed or destroyed"
    task positions: [ :environment ] do
      %w( current upcoming ).each do |group|
        root = email_lists_root( group, 'positions' )
        FileUtils.mkdir_p(root)
        FileUtils.rm( Dir.glob( "#{root}/*" ) - email_list_files(root, Position.all) )
      end
    end

  end

  def email_lists_root( group, type )
    @email_lists_root ||= { }
    return @email_lists_root[ [group,type] ] if @email_lists_root[ [group,type] ]
    @email_lists_root[ [group,type] ] = "#{email_lists_path group}/#{type}"
    FileUtils.mkdir_p( @email_lists_root[ [group,type] ] )
    @email_lists_root[ [group,type] ]
  end

  def email_list_files( path, subjects )
    subjects.map { |subject| "#{path}/#{subject.name :file}" }
  end
  
  def base_email_lists_path
    "#{::Rails.root}/db/uploads/#{::Rails.env}/email_lists"
  end
  
  def email_lists_path( group )
    "#{base_email_lists_path}/#{group}"
  end
  
  def open_email_list_file(path, subject)
    File.open( "#{path}/#{subject.name :file}", 'w' )
  end

  def write_emails_to_file( file, emails )
    emails.each { |email| file << "#{email}\n" }
    file
  end

end

