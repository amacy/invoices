require_relative 'application_controller'
require_relative 'models'

class Invoice < String
  include ApplicationController
  include Models

  attr_reader :hours, :rate

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
  def calc_hrs(invoice_number)
    hrs_array = db.execute("select hrs from line_items where invoice_number = #{invoice_number}")
    @hours = hrs_array.inject(:+).inject(:+).to_s
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
    @rate = line_total.to_s
  end
end

class Biller < Invoice
  def get_row
    db.execute("select * from billers").first
  end
  def name
    @name = get_row[0].to_s
  end
  def street1
    @street1 = get_row[1].to_s
  end
  def street2
    @street2 = get_row[2].to_s
  end
  def city
    @city = get_row[3].to_s
  end
  def state
    @state = get_row[4].to_s
  end
  def zip
    @zip = get_row[5].to_s
  end
  def phone
    @phone = get_row[6].to_s
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

class LineItemsController
  include ApplicationController
  include Models

  attr_accessor :number, :date, :msg, :hrs, :rate, :total

  def index(invoice_number)
    items = db.execute("select * from line_items where invoice_number = #{invoice_number}")
    items.map! do |line|
      item = LineItemsController.new
      item.number = line[1].to_s
      item.date = line[2]
      item.msg = line[3]
      item.hrs = line[4].to_s
      item.rate = line[5].to_s
      item.total = line[4] * line[5]
      item
    end
    items
  end
end

class Commit < LineItemsController
  def date(line)
    @timestamp = line.split(/> /).last.slice(0, 10)
    @timestamp = DateTime.strptime(@timestamp, '%s')
    @timestamp = @timestamp.month.to_s + "/" + @timestamp.day.to_s + "/" + @timestamp.year.to_s.slice(2, 2)
  end
  def msg(line)
    if line.include?("commit:")
      @msg = line.split(/commit:/).last.strip.slice(0, 40)
    elsif line.include?("commit (initial):")
      @msg = line.split(/commit \(initial\):/).last.strip.slice(0, 40)
    end
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
