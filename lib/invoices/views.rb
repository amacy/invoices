require_relative 'helpers/views_helpers'

class InvoicesView < String
  include ViewsHelpers
  def initialize(invoice, line_items, biller, client)
    @invoice, @line_items, @biller, @client = invoice, line_items, biller, client
  end
  def header
    def space(chars)
      " " * (72 - chars) # 72 chars in page width was, 
    end                  # traditionally, the most common
    def line(left, right)
      s = space(left.length + right.length)
      l = left + s + right + "\n"
      if l.strip.empty?
        ""
      else
        l
      end
    end
    def address(person)
      line(person.name, " ") +
      line(person.street1, " ") + 
      line(person.street2, " ") +  
      line(person.city + ", " + person.state + " " + person.zip, " ") + 
      line(person.phone, " ") 
    end
    line("INVOICE #" + @invoice.number, @invoice.date) +
    "\n" +
    address(@biller) +
    "\n" * 2 +
    line("BILL TO:", "") +
    address(@client) +
    "\n" * 2
  end
  def grid
    def border_top
      "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
    end
    def border_bottom
      "----+----------+------------------------------------------+-----+------+" + "\n"
    end
    def total
      "TOTALS:" + (" " * 53) +
      "#{format_hrs(@invoice.total_hrs)}" + 
      divider +
      "#{format_rate(@invoice.total_cost)}" + 
      "\n"
    end
    border_top + 
    "\n" +
    LineItemsView.new.prepare(@line_items).join("\n") +
    "\n" * 2 +
    border_bottom + 
    total
  end
  def render
    header + grid
  end
end

class LineItemsView < String
  include ViewsHelpers
  def format_number(n)
    compare_length(n, 3)
  end
  def format_date(d)
    compare_length(d, 8)
  end
  def format_msg(m)
    compare_length(m, 40)
  end
  def prepare(line_items)
    # Receives an array from LineItemsController
    line_items.map do |item|
      format_number(item.line_number) + divider +
      format_date(item.date) + divider +
      format_msg(item.msg) + divider +
      format_hrs(item.hrs) + divider +
      format_rate(item.rate)
    end
  end
end
