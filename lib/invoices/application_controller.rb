require 'optparse'
require_relative 'controllers/invoices_controller'
require_relative 'controllers/billers_controller'
require_relative 'controllers/clients_controller'
require_relative 'controllers/line_items_controller'
require_relative 'controllers/commits_controller'
require_relative 'models/invoice'
require_relative 'models/biller'
require_relative 'models/client'
require_relative 'models/line_item'
require_relative 'models/commit'
require_relative 'views/invoices_view'

class ApplicationController
  def initialize
    db # Find/create the db
    begin
      Biller.new("").create_billers_table
      Client.new("").create_clients_table
      Invoice.new.create_invoices_table
      #LineItem.new.create_line_items_table
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
          InvoicesController.new(client)
        end
      end,
      'biller' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new biller to the database") do
          BillersController.new
        end
      end,
      'client' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new client to the database") do
          ClientsController.new
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
end
