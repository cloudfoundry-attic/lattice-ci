#!/usr/bin/env ruby

require 'json'

ami_metadata = { "variables" => {} }

$stdin.readlines.each do |line|
  row = line.chomp.split(',')
  if row[2] == "artifact" && row[4] == "id"
    ami_metadata["variables"][row[1]] = { "defaults" => Hash[*row[5].split(/:|%\!\(PACKER_COMMA\)/)] }
  end
end

print ami_metadata.to_json
