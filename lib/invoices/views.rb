class Header < String
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

class Grid < String
  def border_top
    "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
  end
  def border_bottom
    "----+----------+------------------------------------------+-----+------+" + "\n"
  end
  def total(invoice)
    "TOTALS:" + (" " * 53) +
    "#{format_hrs(invoice.calc_hrs(invoice.number.to_i))}" + divider +
    "#{format_rate(invoice.calc_rate(invoice.number.to_i))}" + "\n"
  end
  def divider
    " | "
  end
  def compare_length(string, max_length)
    # raise error if string.length < 0 || string.length > max_length
    if string.length < max_length
      difference = 0
      difference = max_length - string.length
      string + (" " * difference)
    else
      string
    end
  end
  def format_hrs(h)
    compare_length(h, 3)
  end
  def format_rate(amt)
    compare_length("$" + amt, 4)
  end
  def format_all(invoice, line_items)
    border_top + 
    "\n" +
    LineItemsView.new.prepare(line_items).join("\n") +
    "\n" * 2 +
    border_bottom + 
    total(invoice)
  end
end

class LineItemsView < Grid
  def format_number(n)
    compare_length(n, 3)
  end
  def format_date(d)
    compare_length(d, 8)
  end
  def format_msg(m)
    compare_length(m, 40)
  end
  def prepare(line_items) # Receives an array from LineItemsController
    line_items.map do |item|
      format_number(item.number) + divider +
      format_date(item.date) + divider +
      format_msg(item.msg) + divider +
      format_hrs(item.hrs) + divider +
      format_rate(item.rate)
    end
  end
end
