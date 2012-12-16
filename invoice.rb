require "sqlite3"

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

puts "Would you like to create a new invoice? (y/n)"
  if gets.chomp == "y"
  #-------------- FORMATTING ------------#
  # Generate a basic invoice
  def space(chars)
    " " * (72 - chars)
  end

  def line(left, right)
    @space = space(left.length + right.length)
    left + @space + right + "\n"
  end

  def empty_line
    line(" ", " ")
  end

  #--------------- RETRIEVE DATA FROM DB --------------#

  biller = db.execute("select * from billers").first
  client = db.execute("select * from clients").first

  # -------------- HEADER --------------#
  number  = "#" + "0001"
  invoice = "INVOICE " + number
  time    = Time.now
  date    = time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s

  header  = line(biller[0].to_s, invoice) + 
            line(biller[1].to_s, date) + 
            line(biller[2].to_s, " ") + 
            line(biller[3].to_s + ", " + biller[4].to_s + " " + biller[5].to_s, " ") + 
            line(biller[6].to_s, " ") + 
            (empty_line * 3) +
            line("BILL TO:", "") +
            line(client[0].to_s, "") +
            line(client[1].to_s, "") +
          # line(client[2].to_s, "") +
            line(client[3].to_s + ", " + client[4].to_s + " " + client[5].to_s, " ") +
            line(client[6].to_s, "")

  #--------------- INVOICE ITEMS -----------------#

  history = IO.readlines('/Users/aaronmacy/projects/button/.git/logs/HEAD')

  border_top    = "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
  line_item0    = "    +          + " + history[0].split(/: /).last.strip.slice(0, 40) + "\n"
  line_item1    = "    +          + " + history[1].split(/: /).last.strip.slice(0, 40) + "\n"
  line_item2    = "    +          + " + history[2].split(/: /).last.strip.slice(0, 40) + "\n"
  line_item3    = "    +          + " + history[3].split(/: /).last.strip.slice(0, 40) + "\n"
  line_item4    = "    +          + " + history[4].split(/: /).last.strip.slice(0, 40) + "\n"
  border_bottom = "----+----------+------------------------------------------+-----+------+" + "\n"
  total         = "TOTALS:                                                   +     +      +" + "\n"

  invoice_items = border_top + 
                  empty_line + 
                  line_item0 + 
                  line_item1 + 
                  line_item2 + 
                  line_item3 + 
                  line_item4 + 
                  empty_line +
                  border_bottom + 
                  total

  #--------------- WRITE THE FILE ----------------#
  File.open("invoice0001.txt", 'w') do |f|
    f.write(header + (empty_line * 2) + invoice_items)
  end
end
