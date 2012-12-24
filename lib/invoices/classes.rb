class Invoice < String
  def db
    SQLite3::Database.new "test.db"
  end
  def create_biller_table
    db.execute <<-SQL
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
  end
  def create_client_table
    db.execute <<-SQL
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
  end
  def add_row_to_biller_table(name, street1, street2, city, state, zip, phone)
    db.execute("INSERT INTO billers 
               (name, street1, street2, city, state, zip, phone) 
               VALUES (?, ?, ?, ?, ?, ?, ?)", 
               [name, street1, street2, city, state, zip, phone])
  end
  def add_row_to_client_table(name, street1, street2, city, state, zip, phone, rate)
    db.execute("INSERT INTO clients 
               (name, street1, street2, city, state, zip, phone, rate) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
               [name, street1, street2, city, state, zip, phone, rate])
  end
  def create_invoice_table # not being used
    db.execute <<-SQL
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
  end
  def date
    time = Time.now
    time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s
  end
  def format_number(x)
    if x >=  1 && x < 10 then "000#{x}"
    elsif x >= 10 && x < 100 then "00#{x}"
    elsif x >= 100 && x < 1000 then "0#{x}"
    elsif x >= 100 && x < 10000 then "#{x}"
    # raise an exception for x >= 10000
    end
  end
  def number
    i = 1
    Dir.foreach(File.expand_path('~/invoices')) do |filename|
      if filename.include?("invoice#{format_number(i)}.txt")
        i += 1
      else
        format_number(i)
      end
    end
    format_number(i)
  end
end

class Header < Invoice
  def space(chars)
    " " * (72 - chars) # 72 chars in page width was, 
  end                  # traditionally, the most common
  def line(left, right)
    @space = space(left.length + right.length)
    left + @space + right + "\n"
  end
  def format(num, date, biller, client)
    line("INVOICE #" + num, date) +
    "\n" +
    biller +
    "\n" * 2 +
    line("BILL TO:", "") +
    client +
    "\n" * 2
  end
end

class Biller < Header
  def get_row
    db.execute("select * from billers").first
  end
  def name
    get_row[0].to_s
  end
  def street1
    get_row[1].to_s
  end
  def street2
    get_row[2].to_s
  end
  def city
    get_row[3].to_s
  end
  def state
    get_row[4].to_s
  end
  def zip
    get_row[5].to_s
  end
  def phone
    get_row[6].to_s
  end
  def address
    line(name, " ") +
    line(street1, " ") + 
    line(street2, " ") +  
    line(city + ", " + state + " " + zip, " ") + 
    line(phone, " ") 
  end
end

class Client < Biller
  def get_row
    db.execute("select * from clients").first
  end
  def default_rate
    get_row[7].to_s
  end
end

class Grid < Invoice
  def border_top
    "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
  end
  def border_bottom
    "----+----------+------------------------------------------+-----+------+" + "\n"
  end
  def total
    "TOTALS:                                                   +     +      +" + "\n"
  end
  def divider
    " + "
  end
  def format(git_input)
    border_top + 
    "\n" +
    LineItem.new.index(git_input).join("\n") + # Should be LineItem.new.index
    "\n" * 2 +
    border_bottom + 
    total
  end
  def total_hrs

  end
  def total_rate
    
  end
end

class LineItem < Grid
  def compare_length(string, max_length)
    # raise an error if string.length < 0 || string.length > max_length
    if string.length < max_length
      difference = 0
      difference = max_length - string.length
      string + (" " * difference)
    else
      string
    end
  end
  def item_number(n)
    compare_length(n, 3)
  end
  def hrs(h)
    compare_length(h, 3)
  end
  def rate(amt)
    compare_length(amt, 4)
  end
  def compile(n, date, msg, hrs, rate)
    n + divider + date + divider + msg + divider + hrs + divider + rate
  end
  def index(commits) # Should be an array of all LineItem.compile
    i = 0
    commits.map do |commit|
      i += 1
      LineItem.new.compile(item_number(i.to_s), commit.date(line), commit.msg(line), commit.hrs(".5"), commit.rate(Client.new.default_rate))
    end
  end
end

class Commit < LineItem
  def date(line)
    timestamp = line.split(/> /).last.slice(0, 10)
    timestamp = DateTime.strptime(timestamp, '%s')
    timestamp = timestamp.month.to_s + "/" + timestamp.day.to_s + "/" + timestamp.year.to_s.slice(0, 2)
    compare_length(timestamp, 8)
  end
  def msg(line)
    if line.include?("commit:")
      line = line.split(/commit:/).last.strip.slice(0, 40)
    elsif line.include?("commit (initial):")
      line = line.split(/commit \(initial\):/).last.strip.slice(0, 40)
    end
    compare_length(line, 40)
  end
  def index(file) # Should store commits only
    msgs = []
    dates = []
    file.each do |line|
      commit = Commit.new
      stripped_line = commit.msg(line)
      msgs.push(stripped_line)
      stripped_date = commit.date(line)
      dates.push(stripped_date)
    end
    # Merge & turn into a hash that with :date => :msg k/v pairs
  end
end
