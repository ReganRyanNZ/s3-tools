# s3-tools
Tools to make S3 interaction easy-peasy-lemon-squeezy

This might be a gem one day, but for now, it's a copy-paste service class that makes simple S3 use much easier.

## Requirements

- `gem 'aws-sdk', '~> 2.3'`
- `ENV['AWS_REGION']`
- `ENV['AWS_S3_BUCKET']`—only one bucket here. If you want to have lots of files, simply add directory structure.
- Set your "root" in the class, unless you're ok with "files". This lets you have other stuff in the same bucket, kept separate.

## Example use
```
s3_path = S3.root.join("test.txt")
=> #<Pathname:files/test.txt>

path = Rails.root.join("tmp", "test.txt")
file_content = "testing 123"
File.open(path, "w") { |f| f.write file_content }

upload_result = S3.upload path, s3_path
=> #<Pathname:files/test.txt> # s3 path of uploaded file, or nil if the upload didn't work

File.delete path

download_result = S3.download(s3_path, path)
=> "/path/to/server/release/20180313063923/tmp/test.txt" # path of file saved

# redirecting users to this url will cause the file to automatically be downloaded by the user
download_url = S3.download_url(s3_path)
=> "https://servername.s3.ap-southeast-2.amazonaws.com/files/test.txt?lots-of-signature-params"

# point assets to this
public_url = S3.public_url(s3_path)
=> "https://servername.s3.ap-southeast-2.amazonaws.com/files/test.txt?lots-of-signature-params"

# glob can take "*" wildcards, just like Dir.glob
images = S3.glob(S3.root.join("*.jpg"))
=> ["files/images/products/company_name/1/79/43779.jpg", "files/images/products/company_name/1/large/79/43779.jpg", "files/images/products/company_name/1/product/79/43779.jpg", "files/images/products/company_name/1/small/79/43779.jpg", "files/images/products/company_name/1/tiny/79/43779.jpg"]

S3.delete s3_path
=> #<struct Aws::S3::Types::DeleteObjectOutput delete_marker=true, version_id="2RI78S8vkol17bLUUBR9jVcFXC6luD.a", request_charged=nil>

S3.exists? s3_path
=> false
```
