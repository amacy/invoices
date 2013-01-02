require 'optparse'
require_relative 'controllers'
require_relative 'models'
require_relative 'views'

class ApplicationController
  include Models
  def parse_options
    global = OptionParser.new do |opt|
      opt.banner = "Usage: invoices COMMAND [OPTIONS]"
      # --new
      # --list
      # --reprint
      opt.on("-v", "--version", "Check the version of Invoices") do
        puts "v#{INVOICES_VERSION}"
      end
      #opts.on("-b", "--biller", "Select the biller") do
      #end
    end
    subcommands = {
      'invoice' => OptionParser.new do |opt|
        opt.on("-c", "--client CLIENT", "Select the client for this invoice") do |c|
          client = Client.new(c)
          generate_invoice(client)
        end
      end,
     'client' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new client to the database") do
          add_client
        end
      end
    }
    global.order!
    subcommands[ARGV.shift].order!
  end
  def parse_commands
    case ARGV[0]
    when "invoice"
    when "biller"
      add_biller
    when "client"
    end
  end
  def add_biller
    puts "your name >"
    user_name = $stdin.gets.chomp
    puts "street1 >"
    user_street1 = $stdin.gets.chomp
    puts "street2 >"
    user_street2 = $stdin.gets.chomp
    puts "city >"
    user_city = $stdin.gets.chomp
    puts "state (2 letters) >"
    user_state = $stdin.gets.chomp
    puts "zip (5 digits) >"
    user_zip = $stdin.gets.chomp
    puts "phone >"
    user_phone = $stdin.gets.chomp
    add_row_to_billers_table(user_name, user_street1, user_street2, user_city, user_state, user_zip, user_phone)
  end
  def add_client
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
    add_row_to_clients_table(client)
  end
  def generate_invoice(client)
    biller = Biller.new
    invoice = Invoice.new
    invoice_number = invoice.number # Fix this
    header = Header.new
    header = header.format(invoice_number, invoice.date, header.address(biller), header.address(client))
    
    puts "Where is the project root (the parent directory of the git repo)?"
    invoice.project_root($stdin.gets.chomp)
    invoice.git_root
    
    commits_hash = Commit.new.index(invoice.git_root)
    puts "Would you like to enter a different rate for each commit? (y/n)"
    custom_rate = true if $stdin.gets.chomp == "y"
    i = 0
    commits_hash.each do |date, commit|
      puts "\n" + "commit #{i + 1}: " + commit
      puts "how long did this take?"
      commit_hrs = $stdin.gets.chomp
      if custom_rate
        puts "how much will you charge?"
        commit_rate = $stdin.gets.chomp
        invoice.add_row_to_line_items_table(invoice_number.to_i, i + 1, date, commit, commit_hrs, commit_rate)
      else
        invoice.add_row_to_line_items_table(invoice_number.to_i, i + 1, date, commit, commit_hrs, client.default_rate)
      end
      i += 1
    end

    items = LineItemsController.new.index(invoice_number)
    grid = Grid.new.format_all(invoice, items)

    add_row_to_invoices_table(invoice_number, invoice.date, client.id) 
    File.open("#{INVOICES_FOLDER}/invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
    puts "generated invoice#{invoice_number}.txt"
  end
end
