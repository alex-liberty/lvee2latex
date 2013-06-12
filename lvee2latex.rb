#!/usr/bin/env ruby
#
# Usage lvee2latex.rb id > out.tex

require "rubygems"
require "open-uri"
require "json"
require "redcloth"
require "shell"

abort "No id." unless ARGV[0]
fix_bib = true if ARGV[1] == '1'

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

puts '\begin{abstract}'
puts abstract
puts '\end{abstract}'

if fix_bib
  sh = Shell.new
  sed_cmd = <<'EOF'
sed -E '
s/\\footnotemark\[([0-9]+)\]/\\cite\{bib\1\}/g;
s/\\footnotetext\[1\]/\\begin\{thebibliography\}\{9\}\n\\bibitem\{bib1\} /;
s/\\footnotetext\[([0-9]+)\]/\n\\bibitem\{bib\1\} /g;
s/\\section\{/\\section*\{/;
'
EOF
  sed = IO.popen(sed_cmd,'w+')
  # $stderr.write sed_cmd
  sed.write(body)
  sed.close_write
  body = sed.read
  body << '\end{thebibliography}'
end

puts body

puts <<EOF
\\end{document}
EOF
