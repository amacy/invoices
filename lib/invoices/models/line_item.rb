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
  def find_by_invoice_number(invoice_number)
    items = db.execute("select * from line_items where 
                       invoice_number = #{invoice_number}")
    items.map! do |line|
      LineItem.new(line[0].to_s, line[1].to_s, line[2], line[3], line[4].to_s, line[5].to_s)
    end
    items
  end
  def create_line_items_table
    db.execute <<-SQL
      create table line_items (
        invoice_number int,
        line_number int,
        commit_date varchar(10),
        commit_msg varchar,
        hrs int,
        rate int,
        cost int
        );
    SQL
  end
  def save
    db.execute("INSERT INTO line_items 
           (invoice_number, line_number, commit_date, commit_msg, hrs, rate, cost) 
           VALUES (?, ?, ?, ?, ?, ?, ?)", 
           [@invoice_number, @line_number, @date, @msg, @hrs, @rate, @cost])
  end
end
