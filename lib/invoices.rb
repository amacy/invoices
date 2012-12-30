require 'sqlite3'
require_relative 'invoices/classes'
require_relative 'invoices/database'
require_relative 'invoices/user_input'

session = Invoice.new
session.db # Find/create the db
begin
  session.create_billers_table
  session.create_clients_table
  session.create_invoices_table
  session.create_line_items_table
rescue SQLite3::SQLException
end
FOLDER = File.expand_path('~/Invoices')
unless File.directory?(FOLDER)
  Dir.mkdir(FOLDER)
end
# Command Line Prompts
session.add_biller
session.add_client
session.generate_invoice

## TO DO LIST - v0.1.0
#  - Improve semantic naming/organization of classes & methods
#  - Improve instance variable usage
#  - Allow commit messages to be multiple lines
#  - Raise errors where noted (in comments)
#  - Allow queries for multiple billers/clients
#  - Implement MVC code organization
#  - Turn into rubygem
#  - Write tests
#  - Write instructions
#
## Version - v0.2.0
#  - Allow multiple git repos per invoice
#  - Provide control over which commits get added to the invoice
#  - Improve CLI (rather than running a file in Ruby, enter commands by typing "invoices")
#  - Add ability to regenerate invoices
#  - Add ability to preview invoices @ the command line
#  - Allow users to select where they want their invoices to be stored
#
## BUGS
#  - CLI not prompting for first Commit.index date => msg pair in ~
