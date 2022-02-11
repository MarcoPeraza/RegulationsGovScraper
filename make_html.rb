#!/usr/bin/env ruby
require 'erb'
require 'json'

documents = JSON.parse(File.read(ARGV[0]), symbolize_names:true)

template = ERB.new(File.read(__dir__ + "/template.erb"))
puts template.result(binding)