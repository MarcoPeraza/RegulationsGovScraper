#!/usr/bin/env ruby
require 'erb'
require 'json'

if (ARGV.length == 1)
    comments_filename = ARGV[0]
elsif (ARGV.length == 0)
    comments_filename = gets.strip
end

documents = JSON.parse(File.read(comments_filename), symbolize_names:true)

template = ERB.new(File.read(__dir__ + "/template.erb"))
output_html = template.result(binding)
output_filename = File.expand_path(comments_filename + ".html")
File.write(output_filename, output_html)

STDERR.puts "HTML table saved to: #{output_filename}"
puts output_filename unless STDOUT.tty?