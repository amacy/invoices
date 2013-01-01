require 'optparse'
require_relative 'controllers'
require_relative 'models'
require_relative 'views'

module ApplicationController
  include Models
  
  def parse_options
    OptionParser.new do |opt|
      opt.banner = "Usage: invoices COMMAND [OPTIONS]"
      # --new
      # --list
      # --reprint
      opt.on("-v", "--version", "Check the version of Invoices") do
        puts "v#{INVOICES_VERSION}"
      end
    end.parse!
  end

  def parse_commands
    case ARGV[0]
    when "new"
      generate_invoice
    when "biller"
      add_biller
    when "client"
      add_client
    end
  end
  
  def add_biller
    puts "Would you like to enter your information? (y/n)"
    if $stdin.gets.chomp == "y"
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
  end
  def add_client
    puts "Would you like to add a client to the database? (y/n)"
    if $stdin.gets.chomp == "y"
      puts "client name >"
      client_name = $stdin.gets.chomp
      puts "street1 >"
      client_street1 = $stdin.gets.chomp
      puts "street2 >"
      client_street2 = $stdin.gets.chomp
      puts "city >"
      client_city = $stdin.gets.chomp
      puts "state (2 letters) >"
      client_state = $stdin.gets.chomp
      puts "zip (5 digits) >"
      client_zip = $stdin.gets.chomp
      puts "phone >"
      client_phone = $stdin.gets.chomp
      puts "hourly rate you'll charge this client >"
      client_rate = $stdin.gets.chomp
      add_row_to_clients_table(client_name, client_street1, client_street2, client_city, client_state, client_zip, client_phone, client_rate)
    end
  end
  def generate_invoice
    biller = Biller.new
    client = Client.new
    if biller.get_row != nil && client.get_row != nil
      puts "Would you like to create a new invoice? (y/n)"
      if $stdin.gets.chomp == "y"
        invoice = Invoice.new
        invoice_number = invoice.number # Store invoice number in a variable for reuse
        header = Header.new
        header = header.format(invoice_number, invoice.date, header.address(biller), header.address(client))
        
        puts "Where is the project root (the parent directory of the git repo)?"
        root = File.expand_path($stdin.gets.chomp) # Allow relative directories
        if root[-1] == "/" then root.slice!(0..root.length) end # Remove trailing slash

        git_log = IO.readlines("#{root}/.git/logs/HEAD")
        git_log.keep_if { |line| line.include?("commit") }

        commits_hash = Commit.new.index(git_log)
        puts commits_hash # For testing purposes

        puts "Would you like to enter a different rate for each commit? (y/n)"
        if $stdin.gets.chomp == "y"
          i = 0
          commits_hash.each do |date, commit|
            puts "\n" + "commit #{i + 1}: " + commit
            puts "how long did this take?"
            commit_hrs = $stdin.gets.chomp
            puts "how much will you charge?"
            commit_rate = $stdin.gets.chomp
            invoice.add_row_to_line_items_table(invoice_number.to_i, i + 1, date, commit, commit_hrs, commit_rate)
            i += 1
          end
        else
          i = 0
          commits_hash.each do |date, commit|
            puts "\n" + "commit #{i + 1}: " + commit
            puts "how long did this take?"
            commit_hrs = $stdin.gets.chomp
            i += 1
            invoice.add_row_to_line_items_table(invoice_number.to_i, i + 1, date, commit, commit_hrs, client.default_rate)
          end
        end

        items = LineItemsController.new.index(invoice_number)
        grid = Grid.new.format_all(invoice, items)

        File.open("#{FOLDER}/invoice#{invoice_number}.txt", 'w') { |f| f.write(header + grid) }
        puts "generated invoice#{invoice_number}.txt"
      else
        puts "quitting..."
      end
    else
      puts "you must create a biller & a client before you may create an invoice. quitting..."
    end
  end
end
