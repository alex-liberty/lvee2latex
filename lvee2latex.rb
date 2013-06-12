#!/usr/bin/env ruby
#
# Usage lvee2latex.rb id > out.tex

require "rubygems"
require "open-uri"
require "json"
require "redcloth"

if ARGV[0] == nil 
	puts "No id." 
	exit 1
end

id=ARGV[0]
document = JSON.parse(open("http://lvee.org/en/abstracts/#{id}.json").read)

title = document['title']
authors = document['authors']
abstract = document['summary']
body = RedCloth.new(document['body']).to_latex

puts <<EOF
\\documentclass[10pt, a5paper]{article}
\\input{preamble.tex}
\\begin{document}
EOF

puts "\\title{#{title}}"
puts "\\author{#{authors}}"
puts '\\maketitle'

puts body

puts <<EOF
\\end{document}
EOF
