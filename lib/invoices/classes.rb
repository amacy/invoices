require_relative 'user_input'
require_relative 'database'

class Invoice < String
  include UserInput
  include DatabaseHelpers

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
    @line = left + @space + right + "\n"
    if @line.strip.empty?
      ""
    else
      @line
    end
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
    @street2 = get_row[2].to_s
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
  def total(invoice_number)
    "TOTALS:                                                   + #{calc_hrs(invoice_number)} + #{calc_rate(invoice_number)} +" + "\n"
  end
  def divider
    " | "
  end
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
  def hrs(h)
    compare_length(h, 3)
  end
  def rate(amt)
    compare_length("$" + amt, 4)
  end
  def format(invoice_number)
    border_top + 
    "\n" +
    LineItem.new.index(invoice_number).join("\n") +
    "\n" * 2 +
    border_bottom + 
    total(invoice_number)
  end
  def calc_hrs(invoice_number)
    hrs_array = db.execute("select hrs from line_items where invoice_number = #{invoice_number}")
    hrs(hrs_array.inject(:+).inject(:+).to_s)
  end
  def calc_rate(invoice_number)
    rate_array = db.execute("select rate from line_items where invoice_number = #{invoice_number}").inject(:+)
    hrs_array = db.execute("select hrs from line_items where invoice_number = #{invoice_number}").inject(:+)
    i = 0
    line_total = 0
    rate_array.each do |rate|
      line_total += (rate * hrs_array[i])
      i += 1
    end
    rate(line_total.to_s)
  end
end

class LineItem < Grid
  def item_number(n)
    compare_length(n, 3)
  end
  def compile(n, date, msg, hrs, rate)
    n + divider + date + divider + msg + divider + hrs + divider + rate
  end
  def index(invoice_number)
    items = db.execute("select * from line_items where invoice_number = #{invoice_number}")
    items.map do |line|
      @item_number = item_number(line[1].to_s)
      @date = line[2]
      @msg = line[3]
      @hrs = hrs(line[4].to_s)
      @rate = rate(line[5].to_s)
      @total = line[4] * line[5]
      LineItem.new.compile(@item_number, @date, @msg, @hrs, @rate)
    end
  end
end

class Commit < LineItem
  def date(line)
    timestamp = line.split(/> /).last.slice(0, 10)
    timestamp = DateTime.strptime(timestamp, '%s')
    timestamp = timestamp.month.to_s + "/" + timestamp.day.to_s + "/" + timestamp.year.to_s.slice(2, 2)
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
  def index(file)
    # Takes a file as an array of lines and 
    # returns a hash of date => msg pairs
    commits = {}
    file.each do |line|
      commit = Commit.new
      stripped_msg = commit.msg(line)
      stripped_date = commit.date(line)
      commits[stripped_date] = stripped_msg
    end
    commits
  end
end
