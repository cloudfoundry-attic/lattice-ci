#!/usr/bin/env ruby

require 's3'
require 'erb'
require 'ostruct'

service = S3::Service.new(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
)

S3_BUCKET = 'lattice'

objs_by_day = {}
service.buckets.find(S3_BUCKET).objects.each do |obj|
	next if !obj.key.start_with?('nightly/lattice-bundle')
	next if obj.key.start_with?('nightly/lattice-bundle-latest-')

	arch = /-([^-]+)\.zip$/.match(obj.key)[1]
	has_arch = ['osx', 'linux'].include?(arch)
	regex = ( has_arch ? /lattice-bundle-(.+?)-[^-]+\.zip$/ : /lattice-bundle-(.+?)\.zip$/ )
	version = regex.match(obj.key)[1]

	objs_by_day[obj.last_modified.to_date] ||= {}
	objs_by_day[obj.last_modified.to_date][version] ||= []
	objs_by_day[obj.last_modified.to_date][version] << {:arch => (has_arch ? arch : 'download'), :path => obj.key}
end

def binding_from_hash(hash)
	OpenStruct.new(hash).instance_eval { binding }
end

erb = ERB.new(File.read('listing.html.erb'), 0, '>')

nightly_bundle_listing = service.buckets.find(S3_BUCKET).objects.build('nightly/index.html')
nightly_bundle_listing.content = erb.result(binding_from_hash({:days => objs_by_day, :s3bucket => S3_BUCKET}))
nightly_bundle_listing.content_type = "text/html"
nightly_bundle_listing.save

print "Uploaded nightly bundle listing."
