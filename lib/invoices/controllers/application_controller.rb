require 'optparse'
require_relative '../global'
require_relative 'invoices_controller'
require_relative 'billers_controller'
require_relative 'clients_controller'
require_relative 'line_items_controller'
require_relative 'commits_controller'
require_relative '../models/invoice'
require_relative '../models/biller'
require_relative '../models/client'
require_relative '../models/line_item'
require_relative '../models/commit'
require_relative '../views/invoices_view'
require_relative '../../../db/schema'

class ApplicationController
  def initialize
    Schema.new.create_all_tables(INVOICES_DB)
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
          client = Client.new.find_by_name(c)
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
