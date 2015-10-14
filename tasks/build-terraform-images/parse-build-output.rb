#!/usr/bin/env ruby

require 'json'

# 1444848512,,ui,say,--> cell: AMIs were created:\n\nus-east-1: ami-c1d184a4
# 1444848512,brain,artifact-count,1
# 1444848512,brain,artifact,0,builder-id,mitchellh.amazonebs
# 1444848512,brain,artifact,0,id,us-east-1:ami-7bd0851e
# 1444848512,brain,artifact,0,string,AMIs were created:\n\nus-east-1: ami-7bd0851e
# 1444848512,brain,artifact,0,files-count,0
# 1444848512,brain,artifact,0,end
# 1444848512,,ui,say,--> brain: AMIs were created:\n\nus-east-1: ami-7bd0851e

ami_metadata = { "variables" => {} }

$stdin.readlines.each do |line|
  row = line.chomp.split(',')
  if row[2] == "artifact" && row[4] == "id"
    ami_metadata["variables"][row[1]] = { "defaults" => Hash[*row[5].split(/:|%\!\(PACKER_COMMA\)/)] }
  end
end

print ami_metadata.to_json

