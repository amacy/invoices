class Invoice < String
end

class Format < Invoice
  def space(chars)
    " " * (72 - chars) # 72 chars in page width was, traditionally, the most common
  end
  def line(left, right)
    @space = space(left.length + right.length)
    left + @space + right + "\n"
  end
end

class Header < Format
end

class Grid < Format
  def border_top
    "----+-- DATE --+------------- COMMIT MESSAGE -------------+ HRS + RATE +" + "\n"
  end
  def border_bottom
    "----+----------+------------------------------------------+-----+------+" + "\n"
  end
  def total
    "TOTALS:                                                   +     +      +" + "\n"
  end
  def divider
    " + "
  end
  # Process the commits
  def commits(file)
    file.map do |line|
      commit = Commit.new
      LineItem.new.compile(" 1 ", commit.date(line), commit.msg(line), ".5 ", "50")
    end
  end

  def compare_length(string, max)
    if string.length != max
      diff = max - string
      diff * " "
    end
  end
end

class LineItem < Grid
  def n
  end
  def rate
  end
  def compile(n, date, msg, hrs, rate)
    n + divider + date + msg + divider + hrs + rate
  end
end

class Commit < LineItem
  def date(line)
    timestamp = line.split(/> /).last.slice(0, 10)
    timestamp = DateTime.strptime(timestamp, '%s')
    timestamp.month.to_s + "/" + timestamp.day.to_s + "/" + timestamp.year.to_s
  end
  def msg(line)
    line.split(/commit/).last.strip.slice(0, 40) # We only have 40 chars 
  end                                            # width on the invoice
  def hrs
  end
end
