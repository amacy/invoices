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
    choose_db(*boolean).execute("INSERT INTO invoices (invoice_number, date, client_id, total_hrs, total_cost) VALUES (?, ?, ?, ?, ?)", 
                                [@number, @date, @client_id, @total_hrs, @total_cost])
  end

  def add_line_item(line_item)
    @line_items_array << line_item
  end

  def find_by_invoice_number(invoice_number, *boolean)
    invoice = choose_db(*boolean).execute("select * from invoices where invoice_number = #{invoice_number}").first
    @number = invoice[0]
    @date = invoice[1]
    @client_id = invoice[2]
    @total_hrs = invoice[3]
    @total_cost = invoice[4]
    self
  end

  private

    def format(x)
      raise "Invalid invoice number" if x < 1
      return "000#{x}" if (1..9).include?(x)
      return "00#{x}" if (10..99).include?(x)
      return "0#{x}" if (100..999).include?(x) 
      return "#{3}" if  (1000..9999).include?(x)
      raise "Too many invoices!"
    end
end
