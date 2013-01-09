require_relative 'spec_helper'
require_relative '../lib/invoices/controllers/application_controller'
require_relative '../lib/invoices/controllers/invoices_controller'
require_relative '../lib/invoices/controllers/billers_controller'
require_relative '../lib/invoices/controllers/clients_controller'
require_relative '../lib/invoices/controllers/line_items_controller'
require_relative '../lib/invoices/controllers/commits_controller'
=begin
describe ApplicationController do
  before do
    @app = ApplicationController.new
  end

  describe "#initalize" do
    it "should create a db & invoice folder" do
      File.directory?(INVOICES_FOLDER).must_equal true
    end

    it "should create invoices.db" do
      File.exists?(INVOICES_DB).must_equal true
    end

    it "should create test.db" do
      File.exists?(TEST_DB).must_equal true
    end
  end

  #describe "#parse_options" do
  #end

  #describe "#parse_commands" do
  #end
end

describe InvoicesController do
  before do
    @invoices_controller = InvoicesController.new(Client.new)
  end

  describe "#initialize" do
    it "should set some instance variables" do
      @invoices_controller.biller.wont_be_nil
      @invoices_controller.biller.must_be_instance_of Biller
      @invoices_controller.invoice.must_be_instance_of Invoice
    end
  end
end

describe BillersController do
end

describe ClientsController do
end

describe LineItemsController do
end

describe CommitsController do
end
=end
