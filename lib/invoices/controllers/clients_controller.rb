class ClientsController
  def initialize
    client = Client.new("")
    puts "client name >"
    client.name = $stdin.gets.chomp
    puts "street1 >"
    client.street1 = $stdin.gets.chomp
    puts "street2 >"
    client.street2 = $stdin.gets.chomp
    puts "city >"
    client.city = $stdin.gets.chomp
    puts "state (2 letters) >"
    client.state = $stdin.gets.chomp
    puts "zip (5 digits) >"
    client.zip = $stdin.gets.chomp
    puts "phone >"
    client.phone = $stdin.gets.chomp
    puts "hourly rate you'll charge this client >"
    client.rate = $stdin.gets.chomp
    client.save
  end
end
