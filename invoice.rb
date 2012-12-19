# Third party files
require "sqlite3"

# Additional app files
require_relative "layout"

invoice = Invoice.new
invoice.db

begin
# Create biller table
biller_table = invoice.db.execute <<-SQL
  create table billers (
    name varchar(30),
    street1 varchar(30),
    street2 varchar(30),
    city varchar(30),
    state varchar(2),
    zip varchar(5),
    phone varchar(14)
  );
SQL
# Create client table
client_table = invoice.db.execute <<-SQL
  create table clients (
    name varchar(30),
    street1 varchar(30),
    street2 varchar(30),
    city varchar(30),
    state varchar(2),
    zip varchar(5),
    phone varchar(14),
    rate int
  );
SQL
=begin
# Create invoice table
invoice_table = db.execute <<-SQL
  create table invoices (
    number int,
    date varchar(10)
    client_id int,
    commit_date varchar(8),
    commit_msg varchar(40),
    hrs int,
    rate int
  );
SQL
=end
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
  # Generate invoice number & name the file after it
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
  
  # puts "Where is the project root?"
  # root = gets.chomp
  history = IO.readlines('/Users/aaronmacy/projects/button/.git/logs/HEAD')
  history.keep_if { |line| line.include?("commit") }

  grid = Grid.new.format(history)

  puts "generated invoice#{invoice_number}.txt" if File.open("invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
end

## TO DO LIST
#  - Input hours field at CL
#  - Input directory at CL
#  - Improve slicing of commit messages
#  - Raise errors where noted (in comments)
#  - Move header stuffs to objects
#  - Totals
#  - Allow queries for multiple billers/clients
#  - Don't print street2 when it has nc
