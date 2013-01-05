module ViewsHelpers
  def compare_length(string, max_length)
    # raise error if string.length < 0 || string.length > max_length
    string = string.to_s unless string.instance_of?(String) 
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
    compare_length("$" + amt.to_s, 4)
  end
  def divider
    " | "
  end
end
