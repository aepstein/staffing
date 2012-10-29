Spork.prefork do
  module TemporaryFiles
    def temporary_file_path; "#{::Rails.root}/tmp/test"; end
    def temporary_file(name,size)
      FileUtils.mkdir_p temporary_file_path
      file = File.new( "#{temporary_file_path}/#{name}", 'w' )
      size.times { file << 'a' }
      file.close
      $temporary_files ||= Array.new
      $temporary_files << file
      file.path
    end
  end

  World(TemporaryFiles)
end

Spork.each_run do
  Before do
    $temporary_files ||= []
  end

  After do
    data_directory = File.expand_path(File.dirname(__FILE__) + "../../../db/uploads/#{::Rails.env}")
    if File.directory?(data_directory)
      FileUtils.rm_rf data_directory
    end
    while $temporary_files.any?
      file = $temporary_files.pop
      File.unlink file.path if File.exists? file.path
    end
  end
end

