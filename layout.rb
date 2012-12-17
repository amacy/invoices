#---- GRID HELPER METHODS ----#
class Format < String
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

  def compare_length(string, max)
    if string.length != max
      diff = max - string
      diff * " "
    end
  end

  def n
    1
  end

  def date
  end

  def msg
  end

  def hrs
  end

  def rate
  end

  def line(n, date, msg, hrs, rate)
    n + divider + date + msg + divider + hrs + rate + "\n"
  end
end
