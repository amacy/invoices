require_relative 'application_controller'
require_relative 'models'

class Invoice
  include Models
  attr_reader :hours, :rate, :line_items_array
  attr_accessor :client_id, :total_hrs, :total_cost
  def date
    time = Time.now
    @date = time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s
  end
  def format_number(x)
    if x >=  1 && x < 10 then "000#{x}"
    elsif x >= 10 && x < 100 then "00#{x}"
    elsif x >= 100 && x < 1000 then "0#{x}"
    elsif x >= 100 && x < 10000 then "#{x}"
    # raise an exception for x >= 10000
    end
  end
  def calculate_number
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
  def project_root(file)
    # Allow relative directories
    @root = File.expand_path(file)
    # Remove trailing slash
    length = @root.length
    @root.slice!((length - 1)..length) if @root[-1] == "/" 
    @root
  end
  def git_root
    git_log = IO.readlines("#{@root}/.git/logs/HEAD")
    f = File.new("#{@root}/.git/logs/HEAD")
    f.close unless f.closed?
    git_log.keep_if { |line| line.include?("commit") }
  end
  def add_line_items(line_item)
    @line_items_array = []
    i = @line_items_array.length
    @line_items_array[i] = line_item
  end
end

class Biller
  include Models
  attr_accessor :name, :street1, :street2, :city, :state, :zip, :phone
  def initialize(param)
    if param.empty?
    else
      biller = db.execute("select * from billers").first
      @name = biller[0].to_s
      @street1 = biller[1].to_s
      @street2 = biller[2].to_s
      @city = biller[3].to_s
      @state = biller[4].to_s
      @zip = biller[5].to_s
      @phone = biller[6].to_s
    end
  end
end

class Client
  include Models
  attr_accessor :id, :name, :street1, :street2, :city, :state, :zip, :phone, :rate
  def initialize(name)
    if name.empty?
    else
      client = db.execute("select * from clients 
                          where name = '#{name}'").first
      @id = db.execute("select rowid from clients 
                       where name = '#{name}'").first
      @name = client[0].to_s
      @street1 = client[1].to_s
      @street2 = client[2].to_s
      @city = client[3].to_s
      @state = client[4].to_s
      @zip = client[5].to_s
      @phone = client[6].to_s
      @rate = client[7].to_s
    end
  end
end

class LineItemsController
  include Models
  attr_accessor :invoice_number, :line_number, :date, :msg, :hrs, :rate, :cost
  def initialize(invoice_number, line_number, date, msg, hrs, rate)
    @invoice_number, @line_number, @date, @msg, @hrs, @rate = invoice_number, line_number, date, msg, hrs.to_i, rate.to_i
    @cost = @hrs * @rate
  end
  def find_by_invoice_number(invoice_number)
    items = db.execute("select * from line_items where 
                       invoice_number = #{invoice_number}")
    items.map! do |line|
      LineItemsController.new(line[0].to_s, line[1].to_s, line[2], line[3], line[4].to_s, line[5].to_s)
    end
    items
  end
end

class Commit
  def date(line)
    timestamp = line.split(/> /).last.slice(0, 10)
    timestamp = DateTime.strptime(timestamp, '%s')
    @date = timestamp.month.to_s + "/" + timestamp.day.to_s + "/" + timestamp.year.to_s.slice(2, 2)
  end
  def msg(line)
    if line.include?("commit:")
      @msg = line.split(/commit:/).last.strip.slice(0, 40)
    elsif line.include?("commit (initial):")
      @msg = line.split(/commit \(initial\):/).last.strip.slice(0, 40)
    end
  end
  def index(file) # Takes a file as an array of lines and 
    commits = {}  # returns a hash of date => msg pairs
    file.each do |line|
      commit = Commit.new
      stripped_msg = commit.msg(line)
      stripped_date = commit.date(line)
      commits[stripped_date] = stripped_msg
    end
    commits
  end
end
