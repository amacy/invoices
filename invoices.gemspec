require 'rake'

Gem::Specification.new do |s|
  s.name        = 'invoices'
  s.version     = '0.1.0'
  s.summary     = 'Generate invoices at the command line using Git Commits.'
  s.description = 'Generate monospaced .txt invoices at the command line using
                   Git Commits.'
  s.executables  << 'invoices'
  s.requirements << 'sqlite3'
  s.authors     = ['Aaron Macy']
  s.email       = 'aaronmacy@gmail.com'
  s.files       = FileList['lib/invoices/*.rb',
                           'lib/invoices/**/*.rb',
                           'bin/*',
                           'Rakefile',
                           'README.md',
                           'db/*.rb',
                           'spec/*.rb']
  s.homepage    = 'http://github.com/amacy/invoices'
  s.license     = 'MIT'
end
