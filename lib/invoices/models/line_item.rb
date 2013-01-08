class LineItem
  attr_accessor :invoice_number, :line_number, :date, 
                :msg, :hrs, :rate, :cost
  def initialize(invoice_number, line_number, date, msg, hrs, rate)
    @invoice_number = invoice_number
    @line_number = line_number
    @date = date.to_s
    @msg = msg
    @hrs = hrs.to_i
    @rate = rate.to_i
    @cost = @hrs * @rate
  end
  def find_by_invoice_number(invoice_number, *boolean)
    items = choose_db(*boolean).execute("select * from line_items where 
                       invoice_number = #{invoice_number}")
    items.map! do |line|
      LineItem.new(line[0], line[1], line[2], line[3], line[4].to_s, line[5].to_s)
    end
    items
  end
  def save(*boolean)
    choose_db(*boolean).execute("INSERT INTO line_items 
           (invoice_number, line_number, commit_date, commit_msg, hrs, rate, cost) 
           VALUES (?, ?, ?, ?, ?, ?, ?)", 
           [@invoice_number, @line_number, @date, @msg, @hrs, @rate, @cost])
  end
end
