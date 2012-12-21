require 'rake'

Gem::Specification.new do |s|
  s.name        = 'invoices'
  s.version     = '0.1.0'
  s.summary     = "Generate invoices at the command line using Git Commits."
  s.description = "Generate monospaced .txt invoices at the command line using
                   Git Commits."
  s.authors     = ["Aaron Macy"]
  s.email       = 'aaronmacy@gmail.com'
  s.files       = FileList["lib/*.rb"]
  s.homepage    = 'http://github.com/amacy/invoices'
  s.license     = ''
end
