# Third party files
require "sqlite3"
# Additional app files
require_relative "lib/invoice"
require_relative "lib/user_input"

invoice = Invoice.new # Generate a new invoice
invoice.db # Find/create the db
begin
  invoice.create_biller_table
  invoice.create_client_table
rescue SQLite3::SQLException
end

#--------- Begin CL prompts ---------#
puts "Would you like to enter your information? (y/n)"
if gets.chomp == "y"
  puts "your name >"
  username = gets.chomp
  puts "street1 >"
  userstreet1 = gets.chomp
  puts "street2 >"
  userstreet2 = gets.chomp
  puts "city >"
  usercity = gets.chomp
  puts "state (2 letters) >"
  userstate = gets.chomp
  puts "zip (5 digits) >"
  userzip = gets.chomp
  puts "phone >"
  userphone = gets.chomp
  # Store the data
  invoice.db.execute("INSERT INTO billers (name, street1, street2, city, state, zip, phone)
             VALUES (?, ?, ?, ?, ?, ?, ?)", [username, userstreet1, userstreet2, 
                                                usercity, userstate, userzip, 
                                                userphone])
end

# Collect client data @ the command line
puts "Would you like to add a client to the database? (y/n)"
if gets.chomp == "y"
  puts "client name >"
  clientname = gets.chomp
  puts "street1 >"
  clientstreet1 = gets.chomp
  puts "street2 >"
  clientstreet2 = gets.chomp
  puts "city >"
  clientcity = gets.chomp
  puts "state (2 letters) >"
  clientstate = gets.chomp
  puts "zip (5 digits) >"
  clientzip = gets.chomp
  puts "phone >"
  clientphone = gets.chomp
  puts "hourly rate you'll charge this client >"
  clientrate = gets.chomp
  # Store the data
  invoice.db.execute("INSERT INTO clients (name, street1, street2, city, state, zip, phone, rate)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [clientname, clientstreet1, clientstreet2, 
                                                clientcity, clientstate, clientzip, 
                                                clientphone, clientrate])
end

# Generate a new invoice?
puts "Would you like to create a new invoice? (y/n)"
if gets.chomp == "y"
  invoice_number = 0
  i = 1
  Dir.foreach(File.dirname(__FILE__)) do |filename|
    if filename == "invoice#{invoice.format_number(i)}.txt"
      i += 1
    else
      invoice_number = invoice.format_number(i)
    end
  end

  biller = Biller.new
  client = Client.new
  header = Header.new.format(invoice_number, invoice.date, biller.address, client.address)
  
  puts "Where is the project root (the parent directory of the git repo)?"
  root = File.expand_path(gets.chomp) # Allow relative directories
  if root[-1] == "/" then root.slice!(0..root.length) end # Remove trailing slash

  history = IO.readlines("#{root}/.git/logs/HEAD")
  history.keep_if { |line| line.include?("commit") }

  puts "Would you like to enter a different rate for each commit? (y/n)"
  rate_boolean = gets.chomp
  commit_list = Commit.new.index(history, false)
  i = 0
  commits = []
  hours = []
  if rate_boolean == true
    commit_list.each do |commit|
      i += 1
      puts "\n" + "commit #{i}: " + commit
      puts "how long did this take?"
      commits[i] = gets.chomp
      puts "how much will you charge?"
      rates[i] = gets.chomp
    end
  else
    commit_list.each do |commit|
      i += 1
      puts "\n" + "commit #{i}: " + commit
      puts "how long did this take?"
      hours[i] = gets.chomp
    end
  end

  grid = Grid.new.format(history)

  File.open("invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
  puts "generated invoice#{invoice_number}.txt"
else
  puts "quitting..."
end

## TO DO LIST
#  - Input hours at CL
#  - Input rate at CL
#  - Allow commit messages to be multiple lines
#  - Raise errors where noted (in comments)
#  - Totals
#  - Allow queries for multiple billers/clients
#  - Allow multiple git repos per invoice
#  - Don't print street2 when it has nc
#  - Provide control over which commits get added to the invoice
#  - Invoice.generate_number
#  - Create CLI object?
#  - Improved CLI (move cursor left; quit button; enter commands)
#  - Turn into rubygem
#  - Store invoices to database?
#  - Fix Commit.index
#  - Write tests
