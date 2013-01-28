class Invoice
  attr_reader :hours, :rate, :format_number, :line_items_array, :root, :git_log
  attr_accessor :client_id, :total_hrs, :total_cost, :number, :date
  def initialize
    calculate_number
    @line_items_array = []
    @git_log = []
    @total_hrs = 0
    @total_cost = 0
    @date = Time.now.strftime("%m/%d/%y")
  end
  def calculate_number
    def format(x)
      if x >=  1 && x < 10 then "000#{x}"
      elsif x >= 10 && x < 100 then "00#{x}"
      elsif x >= 100 && x < 1000 then "0#{x}"
      elsif x >= 100 && x < 10000 then "#{x}"
      # raise an exception for x >= 10000
      end
    end
    i = 1
    Dir.foreach(File.expand_path('~/invoices')) do |filename|
      if filename.include?("invoice#{format(i)}.txt")
        i += 1
      else
        format(i)
      end
    end
    @number = i
    @format_number = format(i)
  end
  def project_root(file)
    @root = File.expand_path(file)
  end
  def git_root
    File.open("#{@root}/.git/logs/HEAD", "r") do |file|
      file.each_line do |line|
        @git_log << line if line.include?("commit")
      end
    end
  end
  def calculate_total_hrs
    @line_items_array.each do |line_item|
      @total_hrs += line_item.hrs
    end
    @total_hrs
  end
  def calculate_total_cost
    @line_items_array.each do |line_item|
      @total_cost += line_item.cost
    end
    @total_cost
  end
  def save(*boolean)
    calculate_total_hrs
    calculate_total_cost
    choose_db(*boolean).execute("INSERT INTO invoices 
               (invoice_number, date, client_id, total_hrs, total_cost) 
               VALUES (?, ?, ?, ?, ?)", 
               [@number, @date, @client_id, @total_hrs, @total_cost])
  end
  def add_line_item(line_item)
    @line_items_array << line_item
  end
  def find_by_invoice_number(invoice_number, *boolean)
    invoice = choose_db(*boolean).execute("select * from invoices where 
                       invoice_number = #{invoice_number}").first
    @number = invoice[0]
    @date = invoice[1]
    @client_id = invoice[2]
    @total_hrs = invoice[3]
    @total_cost = invoice[4]
    self
  end
end
