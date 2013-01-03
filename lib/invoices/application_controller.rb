require 'optparse'
require_relative 'controllers'
require_relative 'models'
require_relative 'views'

class ApplicationController
  include Models
  def initialize
    db # Find/create the db
    begin
      create_billers_table
      create_clients_table
      create_invoices_table
      create_line_items_table
    rescue SQLite3::SQLException
    end
    Dir.mkdir(INVOICES_FOLDER) unless File.directory?(INVOICES_FOLDER)
  end 
  def parse_options
    global = OptionParser.new do |opt|
      opt.banner = "Usage: invoices COMMAND [OPTIONS]"
      # --new
      # --list
      # --reprint
      opt.on("-v", "--version", "Check the version of 
             Invoices") do
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
      'biller' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new biller to the database") do
          add_biller
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
    when "client"
    end
  end
  def add_biller
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
    add_row_to_billers_table(biller)
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
    biller = Biller.new("real deal") # Fix this
    invoice = Invoice.new
    invoice_number = invoice.calculate_number # Fix this
    invoice.client_id = client.id
    header = Header.new # Fix this
    header = header.format(invoice_number, invoice.date, header.address(biller), header.address(client))
    
    puts "Where is the project root (the parent directory of the git repo)?"
    invoice.project_root($stdin.gets.chomp)
    invoice.git_root
    
    commits_hash = Commit.new.index(invoice.git_root)
    puts "Would you like to enter a different rate for each commit? (y/n)"
    custom_rate = true if $stdin.gets.chomp == "y"
    i = 0
    line_item = nil
    commits_hash.each do |date, commit|
      puts "\n" + "commit #{i + 1}: " + commit
      puts "how long did this take?"
      commit_hrs = $stdin.gets.chomp
      if custom_rate
        puts "how much will you charge?"
        commit_rate = $stdin.gets.chomp
        line_item = LineItemsController.new(invoice_number.to_i, i + 1, date, commit, commit_hrs, commit_rate)
      else
        line_item = LineItemsController.new(invoice_number.to_i, i + 1, date, commit, commit_hrs, client.rate)
      end
      add_row_to_line_items_table(line_item)
      invoice.add_line_items(line_item)
      i += 1
    end
    add_row_to_invoices_table(invoice)
    items = line_item.find_by_invoice_number(invoice_number)
    grid = Grid.new.format_all(invoice, items)

    File.open("#{INVOICES_FOLDER}/invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
    puts "generated invoice#{invoice_number}.txt"
  end
end
