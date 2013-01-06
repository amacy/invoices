class LineItemsController
  def initialize(invoice, commits, client)
    @invoice, @commits_index, @client = invoice, commits, client
    compile_line_items
  end
  def compile_line_items
    puts "Would you like to enter a different rate for each commit? (y/n)"
    custom_rate = true if $stdin.gets.chomp == "y"
    i = 0
    line_item = nil
    @commits_index.each do |commit|
      puts "\ncommit #{i + 1}: " + commit.msg
      puts "how long did this take?"
      item_hrs = $stdin.gets.chomp
      if custom_rate
        puts "how much will you charge?"
        line_item = LineItem.new(@invoice.number, i + 1, commit.date, commit.msg, item_hrs, $stdin.gets.chomp)
      else
        line_item = LineItem.new(@invoice.number, i + 1, commit.date, commit.msg, item_hrs, @client.rate)
      end
      line_item.save
      @invoice.add_line_item(line_item)
      i += 1
    end
  end
end
