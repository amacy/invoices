class BillersController
  def initialize
    biller = Biller.new("")
    puts "your name >"
    biller.name = $stdin.gets.chomp
    puts "street1 >"
    biller.street1 = $stdin.gets.chomp
    puts "street2 >"
    biller.street2 = $stdin.gets.chomp
    puts "city >"
    biller.city = $stdin.gets.chomp
    puts "state (2 letters) >"
    biller.state = $stdin.gets.chomp
    puts "zip (5 digits) >"
    biller.zip = $stdin.gets.chomp
    puts "phone >"
    biller.phone = $stdin.gets.chomp
    biller.add_row_to_billers_table(biller)
  end
end
