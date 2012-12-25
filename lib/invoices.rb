# Third party files
require "sqlite3"
# Additional app files
require_relative "invoices/classes"
require_relative "invoices/user_input"

invoice = Invoice.new
invoice.db # Find/create the db
begin
  invoice.create_biller_table
  invoice.create_client_table
rescue SQLite3::SQLException
end
FOLDER = File.expand_path('~/invoices')
unless File.directory?(FOLDER)
  Dir.mkdir(FOLDER)
end

#--------- Begin CL prompts ---------#
puts "Would you like to enter your information? (y/n)"
if gets.chomp == "y"
  puts "your name >"
  user_name = gets.chomp
  puts "street1 >"
  user_street1 = gets.chomp
  puts "street2 >"
  user_street2 = gets.chomp
  puts "city >"
  user_city = gets.chomp
  puts "state (2 letters) >"
  user_state = gets.chomp
  puts "zip (5 digits) >"
  user_zip = gets.chomp
  puts "phone >"
  user_phone = gets.chomp
  invoice.add_row_to_biller_table(user_name, user_street1, user_street2, user_city, user_state, user_zip, user_phone)
end

# Collect client data @ the command line
puts "Would you like to add a client to the database? (y/n)"
if gets.chomp == "y"
  puts "client name >"
  client_name = gets.chomp
  puts "street1 >"
  client_street1 = gets.chomp
  puts "street2 >"
  client_street2 = gets.chomp
  puts "city >"
  client_city = gets.chomp
  puts "state (2 letters) >"
  client_state = gets.chomp
  puts "zip (5 digits) >"
  client_zip = gets.chomp
  puts "phone >"
  client_phone = gets.chomp
  puts "hourly rate you'll charge this client >"
  client_rate = gets.chomp
  invoice.add_row_to_client_table(client_name, client_street1, client_street2, client_city, client_state, client_zip, client_phone, client_rate)
end

# Generate a new invoice?
puts "Would you like to create a new invoice? (y/n)"
if gets.chomp == "y"
  invoice_number = invoice.number # Store invoice number in a variable for reuse
  biller = Biller.new
  client = Client.new
  header = Header.new.format(invoice_number, invoice.date, biller.address, client.address)
  
  puts "Where is the project root (the parent directory of the git repo)?"
  root = File.expand_path(gets.chomp) # Allow relative directories
  if root[-1] == "/" then root.slice!(0..root.length) end # Remove trailing slash

  history = IO.readlines("#{root}/.git/logs/HEAD")
  history.keep_if { |line| line.include?("commit") }

  commits_hash = Commit.new.index(history)
  commit_msgs_array = []
  rates = []
  puts commits_hash # For testing purposes

  puts "Would you like to enter a different rate for each commit? (y/n)"
  if gets.chomp == "y"
    i = 0
    commits_hash.each_value do |commit|
      puts "\n" + "commit #{i + 1}: " + commit
      puts "how long did this take?"
      commit_msgs_array[i] = gets.chomp
      puts "how much will you charge?"
      rates[i] = gets.chomp
      i += 1
    end
  else
    i = 0
    commits_hash.each_value do |commit|
      puts "\n" + "commit #{i + 1}: " + commit
      puts "how long did this take?"
      rates[i] = gets.chomp
      i += 1
    end
  end

  grid = Grid.new.format(history)

  File.open("#{FOLDER}/invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
  puts "generated invoice#{invoice_number}.txt"
else
  puts "quitting..."
end

## TO DO LIST - v0.1.0
#  - Store invoices to database
#  - Input hours at CL
#  - Input rate at CL
#  - Allow commit messages to be multiple lines
#  - Raise errors where noted (in comments)
#  - Totals
#  - Allow queries for multiple billers/clients
#  - Don't print street2 when it has nc
#  - Allow users to select where they want their invoices to be stored
#  - Implement MVC code organization
#  - Turn into rubygem
#  - Write tests
#  - Write instructions
#
## Version - v0.2.0
#  - Allow multiple git repos per invoice
#  - Provide control over which commits get added to the invoice
#  - Improve CLI (rather than running a file in Ruby, enter commands by typing "invoices")
#
## BUGS
#  - CLI not prompting for Commit.index date => msg pair
#  - Date printing first 2 digits of year instead of last 2 digits
