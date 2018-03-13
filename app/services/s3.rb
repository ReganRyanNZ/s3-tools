class S3
  class << self
    def root
      Pathname.new('files')
    end

    def store_files_locally?
      !Rails.env.staging? && !Rails.env.production?
    end

    def upload(local_filename, s3_filename, options={})
      return if store_files_locally?
      options[:acl] = 'public-read' unless options[:acl]

      File.open(local_filename, 'r') do |f|
        bucket.object(s3_filename.to_s).upload_file(f, options)
      end
      s3_filename
    end

    def download(s3_filename, local_filename)
      return if store_files_locally?
      bucket.object(s3_filename.to_s).get(response_target: local_filename.to_s)
      local_filename.to_s
    end

    def exists?(s3_filename)
      return if store_files_locally?
      bucket.object(s3_filename.to_s).exists?
    end

    def glob(filename_pattern)
      return if store_files_locally?
      prefix = filename_pattern.sub(/\*.*/, "")
      regex = /.*/
      if filename_pattern =~ /\*/
        # this is designed to imitate Dir.glob, so '*' is a wildcard
        regex = Regexp.new filename_pattern[/\*.*/].gsub("*", ".*")
      end
      bucket.objects(prefix: prefix).map(&:key).select{|key| key.match(regex)}
    end

    def delete(s3_filename)
      return if store_files_locally?
      bucket.object(s3_filename.to_s).delete
    end

    def public_url(s3_filename)
      return if store_files_locally?
      bucket.object(s3_filename.to_s).presigned_url(:get)
    end

    def download_url(s3_filename, download_filename=nil)
      return if store_files_locally?
      s3_filename = s3_filename.to_s
      download_filename ||= s3_filename.split('/').last
      url_options = {
        expires_in:                   60.minutes,
        response_content_disposition: "attachment; filename=\"#{download_filename}\""
      }
      object = bucket.object(s3_filename)
      object.exists? ? object.presigned_url(:get, url_options).to_s : nil
    end

    private

    def bucket
      @bucket ||= Aws::S3::Resource.new(region: ENV['AWS_REGION']).bucket(ENV['AWS_S3_BUCKET'])
    end
  end
end