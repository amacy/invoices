#---- GRID HELPER METHODS ----#
def space(chars)
  " " * (72 - chars) # 72 chars in page width was, traditionally, the most common
end

def line(left, right)
  @space = space(left.length + right.length)
  left + @space + right + "\n"
end

def empty_line
  line(" ", " ")
end

#----- GRID METHODS ----#
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
