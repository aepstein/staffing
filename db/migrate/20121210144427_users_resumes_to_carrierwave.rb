class UsersResumesToCarrierwave < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def up
    prefix = "#{::Rails.root}/db/uploads/#{::Rails.env}/users"
    say_with_time "Converting resumes into new storage location and naming convention" do
      User.where("resume IS NOT NULL").all.each do |user|
        partitioned_path = ("%09d" % user.id).scan(/\d{3}/).join("/")
        update_stamp = if user.resume_updated_at?
          user.resume_updated_at.to_s :number
        else
          user.updated_at.to_s :number
        end
        new_name = "resume_#{update_stamp}.pdf"
        new_dir = "#{prefix}/#{partitioned_path}"
        new_path = "#{new_dir}/#{new_name}"
        old_dir = "#{prefix}/resumes/#{partitioned_path}/original"
        old_path = "#{old_dir}/#{user.resume}"
        # Normal situation - move file and record in database
        if File.exists? old_path
          FileUtils::mkdir_p new_dir
          FileUtils::mv old_path, new_path
          user.update_column :resume, new_name
        # Maybe the file was already moved but not recorded in database, record it now
        elsif File.exists?( new_path ) && user.resume != new_name
          user.update_column :resume, new_name
        # If for some reason there is no file, dereference in database
        else
          user.update_column :resume, nil
        end
        # Clean up empty directories in old tree (up to prefix)
        while old_path.sub!( /\/[^\/]+$/, '' ) != prefix do
          Dir.rmdir old_path if Dir["#{old_path}/*"].empty?
        end
      end
      say Dir["#{prefix}/resumes/*/*/*/original/*.pdf"].length.to_s + " orphaned resume files left untouched"
    end
    remove_column :users, :resume_updated_at
    remove_column :users, :resume_file_size
    remove_column :users, :resume_content_type
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

