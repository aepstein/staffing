namespace :email_list do
  desc "Building email lists for each committee."
  task :build => [ :environment ] do
    root = "#{RAILS_ROOT}/db/uploads/#{RAILS_ENV}/email_lists/current"
    FileUtils.mkdir_p(root)
    Committee.all.each do |committee|
      file = File.open(root + "/#{committee.name :email}",'w')
      committee.current_emails.each do |email|
        file << "#{email}\n"
      end
      file.close
    end
  end
end

