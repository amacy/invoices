# Third party files
require "sqlite3"

# Additional app files
require_relative "layout"

# ------------ DATABASE ------------#
# Open a database
db = SQLite3::Database.new "test.db"

begin
# Create biller table
biller_table = db.execute <<-SQL
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
client_table = db.execute <<-SQL
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
  db.execute("INSERT INTO billers (name, street1, street2, city, state, zip, phone)
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
  db.execute("INSERT INTO clients (name, street1, street2, city, state, zip, phone, rate)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)", [clientname, clientstreet1, clientstreet2, 
                                                clientcity, clientstate, clientzip, 
                                                clientphone, clientrate])
end

# Generate a new invoice
puts "Would you like to create a new invoice? (y/n)"
if gets.chomp == "y"
  #--------------- RETRIEVE DATA FROM DB --------------#
  biller = db.execute("select * from billers").first
  client = db.execute("select * from clients").first

  # -------------- HEADER --------------#
  # Generate invoice number & name the file after it
  def number(x)
    if x >=  1 && x < 10 then "000#{x}"
    elsif x >= 10 && x < 100 then "00#{x}"
    elsif x >= 100 && x < 1000 then "0#{x}"
    elsif x >= 100 && x < 10000 then "#{x}"
    # raise an exception for x >= 10000
    end
  end

  i = 1
  Dir.foreach(File.dirname(__FILE__)) do |filename|
    if filename == "invoice#{number(i)}.txt"
      i += 1
    else
      number(i)
    end
  end
  
  # Get the date
  time = Time.now
  date = time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s

  header = Header.new

  header_lines = 
    header.line(biller[0].to_s, "INVOICE #" + number(i)) +
    header.line(biller[1].to_s, date) + 
    header.line(biller[2].to_s, " ") + 
    header.line(biller[3].to_s + ", " + biller[4].to_s + " " + biller[5].to_s, " ") + 
    header.line(biller[6].to_s, " ") + 
    "\n" * 3 +
    header.line("BILL TO:", "") +
    header.line(client[0].to_s, "") +
    header.line(client[1].to_s, "") +
    # header.line(client[2].to_s, "") +
    header.line(client[3].to_s + ", " + client[4].to_s + " " + client[5].to_s, " ") +
    header.line(client[6].to_s, "") +
    "\n" * 2
  
  #--------------- GRID OF LINE ITEMS -----------------#

  # puts "Where is the project root?"
  # root = gets.chomp

  history = IO.readlines('/Users/aaronmacy/projects/button/.git/logs/HEAD')
  history.keep_if { |line| line.include?("commit") }

  grid = Grid.new
  grid_lines = grid.border_top + 
               "\n" +
               grid.commits(history).join("\n") +
               "\n" * 2 +
               grid.border_bottom + 
               grid.total

  #--------------- WRITE THE FILE ----------------#
  File.open("invoice#{number(i)}.txt", 'w') do |f|
    f.write(header_lines + grid_lines)
  end
end
