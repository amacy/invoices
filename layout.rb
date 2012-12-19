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
    i = 0
    file.map do |line|
      i += 1
      commit = Commit.new
      LineItem.new.compile(commit.item_number(i.to_s), commit.date(line), commit.msg(line), commit.hrs(".5"), commit.rate("50"))
    end
  end
end

class LineItem < Grid
  def compare_length(string, max_length)
    # raise an error if string.length < 0 || string.length > max_length
    if string.length < max_length
      difference = 0
      difference = max_length - string.length
      string + (" " * difference)
    else
      string
    end
  end
  def item_number(n)
    compare_length(n, 3)
  end
  def rate(amt)
    compare_length(amt, 4)
  end
  def compile(n, date, msg, hrs, rate)
    n + divider + date + divider + msg + divider + hrs + divider + rate
  end
end

class Commit < LineItem
  def date(line)
    timestamp = line.split(/> /).last.slice(0, 10)
    timestamp = DateTime.strptime(timestamp, '%s')
    timestamp = timestamp.month.to_s + "/" + timestamp.day.to_s + "/" + timestamp.year.to_s.slice(0, 2)
    compare_length(timestamp, 8)
  end
  def msg(line)
    line = line.split(/commit/).last.strip.slice(0, 40)
    compare_length(line, 40)
  end                                            
  def hrs(h)
    compare_length(h, 3)
  end
end
