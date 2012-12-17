# Third party files
require "sqlite3"

# Additional app files
require_relative "layout"

# ------------ DATABASE ------------#
# Open a database
db = SQLite3::Database.new "test.db"

begin
# Create biller records
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

# Create client records
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
rescue SQLite3::SQLException
end

# Collect user data @ the command line
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
  number  = "#" + "0001"
  invoice = "INVOICE " + number
  time    = Time.now
  date    = time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s

  header = Header.new

  header_lines = 
    header.line(biller[0].to_s, invoice) +
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
  

  #--------------- INVOICE ITEMS -----------------#

  # puts "Where is the project root?"
  # root = gets.chomp

  history = IO.readlines('/Users/aaronmacy/projects/button/.git/logs/HEAD')
  
  def convert_date(timestamp) 
    DateTime.strptime(timestamp, '%s')
  end
  
  timestamp1 = history[0].split(/> /).last.slice(0, 10)
  timestamp2 = history[1].split(/> /).last.slice(0, 10)
  timestamp3 = history[2].split(/> /).last.slice(0, 10)
  date1 = convert_date(timestamp1)
  date1 = date1.month.to_s + "/" + date1.day.to_s + "/" + date1.year.to_s
  date2 = convert_date(timestamp2)
  date2 = date2.month.to_s + "/" + date2.day.to_s + "/" + date2.year.to_s  
  date3 = convert_date(timestamp3)
  date3 = date3.month.to_s + "/" + date3.day.to_s + "/" + date3.year.to_s  

  commit1 = history[0].split(/commit/).last.strip.slice(0, 40)
  commit2 = history[1].split(/commit/).last.strip.slice(0, 40)
  commit3 = history[2].split(/commit/).last.strip.slice(0, 40)


  grid = Grid.new
  line1 = grid.line(" 1 ", date1, commit1, ".5 ", client[7].to_s)
  line2 = grid.line(" 2 ", date2, commit2, ".5 ", client[7].to_s)
  line3 = grid.line(" 3 ", date3, commit3, ".5 ", client[7].to_s)

  grid_lines = grid.border_top + 
               "\n" + 
               line1 +
               line2 + 
               line3 + 
               "\n" +
               grid.border_bottom + 
               grid.total

  #--------------- WRITE THE FILE ----------------#
  File.open("invoice0001.txt", 'w') do |f|
    f.write(header_lines + grid_lines)
  end
end
