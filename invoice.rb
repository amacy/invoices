# Generate a basic invoice
def space(chars)
  " " * (72 - chars)
end

def line(left, right)
  @space = space(left.length + right.length)
  left + @space + right + "\n"
end

def empty_line
  line(" ", " ")
end

# -------------- HEADER --------------#
# Biller info
name    = "Aaron Macy"
street1 = "31 Angell Ct"
street2 = "Apt 106"
city    = "Stanford"
state   = "CA"
zip     = "94305"
phone   = "(207) 756-9457"

# Debtor info
def debtor
  def name
    "Some Person"
  end

  def street1
    "A St"
  end

  def street2
    "" 
  end

  def city
    "San Francisco"
  end

  def state
    "CA"
  end

  def zip
    "SOMA"
  end

  def phone
    "(555) 555-5555"
  end
end

# Formatting variables
number  = "#" + "0001"
invoice = "INVOICE " + number
time    = Time.now
date    = time.month.to_s + "/" + time.day.to_s + "/" + time.year.to_s

header  = line(name, invoice) + 
          line(street1, date) + 
          line(street2, " ") + 
          line(city + ", " + state + " " + zip, " ") + 
          line(phone, " ") + 
          (empty_line * 3) +
          line("BILL TO:", "") +
          line(debtor.name, "") +
          line(debtor.street1, "") +
        # line(debtor.street2, "") +
          line(debtor.city, "") +
          line(debtor.state, "") +
          line(debtor.zip, "") +
          line(debtor.phone, "")

#--------------- INVOICE ITEMS -----------------#

history = IO.readlines('/Users/aaronmacy/projects/button/.git/logs/HEAD')

border_top    = "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
line_item0    = "    +          + " + history[0].split(/: /).last.strip.slice(0, 40) + "\n"
line_item1    = "    +          + " + history[1].split(/: /).last.strip.slice(0, 40) + "\n"
line_item2    = "    +          + " + history[2].split(/: /).last.strip.slice(0, 40) + "\n"
line_item3    = "    +          + " + history[3].split(/: /).last.strip.slice(0, 40) + "\n"
line_item4    = "    +          + " + history[4].split(/: /).last.strip.slice(0, 40) + "\n"
border_bottom = "----+----------+------------------------------------------+-----+------+" + "\n"
total         = "TOTALS:                                                   +     +      +" + "\n"

invoice_items = border_top + 
                empty_line + 
                line_item0 + 
                line_item1 + 
                line_item2 + 
                line_item3 + 
                line_item4 + 
                empty_line +
                border_bottom + 
                total

#--------------- WRITE THE FILE ----------------#
File.open("invoice0001.txt", 'w') do |f|
  f.write(header + (empty_line * 2) + invoice_items)
end
