# By design the S3 class will return nil in development or testing environments.
# This task is to be run on staging/prod servers via ssh and rails console.

namespace :test do
  desc 'Test that the S3 class is interfacing with AWS S3 correctly (for testing staging and prod servers)'
  task s3: :environment do
    test_s3
  end

  def test_s3
    path = Rails.root.join("tmp", "test.txt")
    s3_path = S3.root.join("test.txt")
    file_content = "testing 123"
    File.open(path, "w") { |f| f.write file_content }

    bucket = S3.send(:bucket)
    return puts "Error getting S3 bucket" unless bucket.is_a? Aws::S3::Bucket

    upload_result = S3.upload path, s3_path
    File.delete path
    return puts "Error uploading #{s3_path} on S3" unless upload_result == s3_path
    return puts "Can't find #{s3_path} on S3" unless S3.exists?(s3_path)

    download_result = S3.download(s3_path, path)
    return puts "Error downloading #{s3_path} from S3 to #{path}" unless File.exists?(download_result) && File.read(path) == file_content
    File.delete path

    download_url = S3.download_url(s3_path)
    return puts "Error getting download url for #{s3_path}" unless download_url[/amazonaws.com/]

    public_url = S3.public_url(s3_path)
    return puts "Error getting public url for #{s3_path}" unless public_url[/amazonaws.com/]

    S3.delete s3_path
    return puts "Error deleting #{s3_path}" if S3.exists? s3_path

    puts "All tests pass!"
  end
end