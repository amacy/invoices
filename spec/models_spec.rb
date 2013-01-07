require_relative 'spec_helper'
require_relative '../lib/invoices/models/invoice'
require_relative '../lib/invoices/models/biller'
require_relative '../lib/invoices/models/client'
require_relative '../lib/invoices/models/line_item'
require_relative '../lib/invoices/models/commit'

describe Invoice do
  before do
    @invoice = Invoice.new
  end

  describe "#initialize" do
    it "should set some instance variables" do
      @invoice.number.must_be :>, 0 # Also tests #calculate_number
      @invoice.format_number.must_be_instance_of String
      @invoice.date.must_equal Time.now.strftime("%m/%d/%y")
      @invoice.line_items_array.must_be_instance_of Array
      @invoice.total_hrs.must_equal 0
      @invoice.total_cost.must_equal 0
    end
  end

  describe "#project_root" do
    before do
      @invoice.project_root('~') # Universalize
    end

    it "should set the file path" do
      @invoice.root.must_equal File.expand_path('~')
    end

    describe "#git_root" do
      before do
        @invoice.git_root
      end

      specify { @invoice.git_log.must_be_instance_of Array }
      specify { @invoice.git_log.each { |line| line.must_include "commit" }}

      it "should close the git log file" do
        skip "File is not closing properly"
        assert(File.new(File.expand_path('~/.git/logs/HEAD')).closed?)
      end

      describe "add line items & calculate totals" do
        before do
          item1 = LineItem.new(@invoice.number, 1, @invoice.date, "Lorem ipsum", 7, 20)
          item2 = LineItem.new(@invoice.number, 2, @invoice.date, "Lipsum", 5, 15)
          @invoice.add_line_item(item1)
          @invoice.add_line_item(item2)
          @invoice.calculate_total_hrs
          @invoice.calculate_total_cost
        end
        
        specify { @invoice.total_hrs.must_equal 12 }
        specify { @invoice.total_cost.must_equal 215 }
        specify { @invoice.line_items_array.first.must_be_instance_of LineItem }
      end
    end
  end
end

describe Biller do # Fix after creating invoices_test.db
  before do
    @biller = Biller.new("real deal") # Fix
  end

  describe "#initialize" do
    it "should set instance variables from the database" do
      @biller.name.wont_be_empty
      @biller.street1.wont_be_nil
      @biller.street2.wont_be_empty
      @biller.city.wont_be_empty
      @biller.state.wont_be_empty
      @biller.zip.wont_be_empty
      @biller.phone.wont_be_empty
      #@biller.email.wont_be_empty
    end
  end
end

describe Client do # Fix after creating invoices_test.db
  before do
    #@client = Client.new('"Peter Simon"') # Fix
  end

  describe "#initialize" do
    it "should set instance variables from the database" do
      skip "db query not working"
      @client.id.must_be :>, 0
      @client.name.wont_be_empty
      @client.street1.wont_be_nil
      @client.street2.wont_be_empty
      @client.city.wont_be_empty
      @client.state.wont_be_empty
      @client.zip.wont_be_empty
      @client.phone.wont_be_empty
      #@client.email.wont_be_empty
      @client.rate.wont_be_empty
    end
  end
end

describe LineItem do
  before do
    @line_item1 = LineItem.new(1, 1, Time.now, "Lorem ipsum", 7, 20)
    @line_item2 = LineItem.new(1, 2, Time.now, "Lipsum", 5, 15)
  end

  describe "#generate_line_number" do
    it "should add a line number" do
    skip "this needs to be moved from the controller to the model"
    end
  end

  describe "#find_by_invoice_number" do # Fix after initialize is fixed
    before do
      # Uncomment after the test.db is added
      #@line_item1.save
      #@line_item2.save
    end
  end
end

describe Commit do
  before do
    line = "0000000000000000000000000000000000000000 847657c5752fb6de037f7ed1da964c702952867d Aaron Macy <aaronmacy@gmail.com> 1355558298 -0800	commit (initial): initial commit"
    @commit = Commit.new(line)
  end

  describe "#parse_date" do
    it "should convert the Unix timestamp to Time object" do
      @commit.date.must_be_instance_of Time
    end
  end

  describe "#parse_msg" do
    it "should strip the commit message to a string of <= 40 chars" do
      @commit.msg.must_be_instance_of String
      @commit.msg.length.must_be :<=, 40
    end
  end
end
