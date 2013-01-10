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
    options = {}
    subcommand_help = "\nExamples:\nCreate an invoice: invoices invoice -c 'Client Name'\nCreate a biller:   invoices biller -n\nCreate a client:   invoices client -n"
    @global = OptionParser.new do |opt|
      opt.banner = "Usage: invoices options [subcommand [options]]"
      opt.on("-v", "--version", "Check the version of Invoices") do# |v|
        #options[:version] = v
        puts "v#{INVOICES_VERSION}"
      end
      opt.on("-h", "--help", "Get some help") do# |v|
        #options[:help] = v
        puts @global
        puts subcommand_help
      end
    end
    subcommands = {
      'invoice' => OptionParser.new do |opt|
        opt.on("-c", "--client CLIENT", "Select the client for this invoice") do |v|
          #option[:client] = v
          client = Client.new.find_by_name(v)
          InvoicesController.new(client)
        end
      end,
      'biller' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new biller to the database") do# |v|
          #option[:biller_new] = v
          BillersController.new
        end
      end,
      'client' => OptionParser.new do |opt|
        opt.on("-n", "--new", "Add a new client to the database") do# |v|
          #option[:client_new] = v
          ClientsController.new
        end
      end
    }
    @global.order!
    cmd = ARGV.shift
    if cmd #&& subcommands.key?(cmd.to_sym)
      subcommands[cmd].order!
    else
      puts @global
      puts subcommand_help
    end
  end
  def parse_commands
    case ARGV[0]
    when "invoice"
    when "biller"
    when "client"
    end
  end
end
