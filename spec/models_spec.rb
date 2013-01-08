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

      describe "#add_line_item" do
        before do
          item1 = LineItem.new(@invoice.number, 1, @invoice.date, "Lorem ipsum", 7, 20)
          item2 = LineItem.new(@invoice.number, 2, @invoice.date, "Lipsum", 5, 15)
          @invoice.add_line_item(item1)
          @invoice.add_line_item(item2)
        end

        it "should create an array of LineItem objects" do
          @invoice.line_items_array[0].must_be_instance_of LineItem
        end

        describe "#save" do
          before do
            @invoice.save(THIS_IS_A_TEST)
          end
          
          it "should call #calculate_total_hrs" do
            @invoice.total_hrs.must_equal 12
          end

          it "should call #calculate_total_cost" do
            @invoice.total_cost.must_equal 215
          end

          describe "#find_by_invoice_number" do
            before do
              @invoice_query = Invoice.new.find_by_invoice_number
            end
              
            it "should set instance variables from the database" do
              @invoice.number.must_equal @invoice_query.number
              @invoice.date.must_equal @invoice_query.date
              @invoice.client_id.must_equal @invoice_query.client_id
              @invoice.total_hrs.must_equal @invoice_query.total_hrs
              @invoice.total_cost.must_equal @invoice_query.total_cost
            end
          end
        end
      end
    end
  end
end

describe Biller do
  before do
    @biller = Biller.new
    @biller.name = "Aaron Burr"
    @biller.street1 = "VP"
    @biller.street2 = ""
    @biller.city = "Washington"
    @biller.state = "DC"
    @biller.zip = "12345"
    @biller.phone = "Telegram"
    # email
  end

  describe "#save" do
    before do
      @biller.save(THIS_IS_A_TEST)
    end

    describe "#find_by_name" do
      before do
        @biller_query = Biller.new.find_by_name("Aaron Burr")
      end

      it "should set instance variables from the database" do
        @biller.name.must_equal @biller_query.name
        @biller.street1.must_equal @biller_query.street1
        @biller.street2.must_equal @biller_query.street2
        @biller.city.must_equal @biller_query.city
        @biller.state.must_equal @biller_query.state
        @biller.zip.must_equal @biller_query.zip
        @biller.phone.must_equal @biller_query.phone
        #@biller.email.must_equal @biller_query.email
      end
    end
  end
end

describe Client do
  before do
    @client = Client.new
  end

  describe "#save" do
    before do
      @client.save(THIS_IS_A_TEST)
    end

    describe "#find_by_name" do
      before do
        @client_query = Biller.new.find_by_name("Alexander Hamilton")
        @client_query.id = choose_db.execute("select rowid from clients 
                                     where name = 'Alexander Hamilton'").first

      end

      it "should set instance variables from the database" do
        @client.id.must_equal @client_query.id
        @client.name.must_equal @client_query.name
        @client.street1.must_equal @client_query.street1
        @client.street2.must_equal @client_query.street2
        @client.city.must_equal @client_query.city
        @client.state.must_equal @client_query.state
        @client.zip.must_equal @client_query.zip
        @client.phone.must_equal @client_query.phone
        #@client.email.must_equal @client_query.email
        @client.rate.must_equal @client_query.rate
      end
    end
  end
end

describe LineItem do
  before do
    @line_item1 = LineItem.new(7, 1, Time.now, "Lorem ipsum", 7, 20)
    @line_item2 = LineItem.new(7, 2, Time.now, "Lipsum", 5, 15)
  end

  describe "#generate_line_number" do
    it "should add a line number" do
    skip "this needs to be moved from the controller to the model"
    end
  end

  describe "#save" do
    before do
      @line_item1.save(THIS_IS_A_TEST)
      @line_item2.save(THIS_IS_A_TEST)
    end

    describe "#find_by_invoice_number" do
      before do
        line_item_query = LineItem.new.find_by_invoice_number(7)
        @line1 = line_item_query.first
        @line2 = line_item_query.second
      end

      it "should set instance variables from the database" do
        @line_item1.invoice_number.must_equal @line1.invoice_number
        @line_item1.line_number.must_equal @line1.line_number
        @line_item1.date.must_equal @line1.date
        @line_item1.msg.must_equal @line1.msg
        @line_item1.hrs.must_equal @line1.hrs
        @line_item1.rate.must_equal @line1.rate
        @line_item1.cost.must_equal @line1.cost
        @line_item2.invoice_number.must_equal @line2.invoice_number
        @line_item2.line_number.must_equal @line2.line_number
        @line_item2.date.must_equal @line2.date
        @line_item2.msg.must_equal @line2.msg
        @line_item2.hrs.must_equal @line2.hrs
        @line_item2.rate.must_equal @line2.rate
        @line_item2.cost.must_equal @line2.cost
      end
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
