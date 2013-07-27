module ViewsHelpers

  def compare_length(string, max_length)
    raise "String too long" if string.length > max_length
    string = string.to_s # Necessary?
    return string if string.length == max_length
    # if string.length < max_length
    delta = max_length - string.length
    string + (" " * delta)
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
