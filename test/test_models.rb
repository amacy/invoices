require 'minitest/autorun'
require 'sqlite3'
require_relative '../lib/invoices/global'
require_relative '../lib/invoices/models/biller'

class TestBiller < MiniTest::Unit::TestCase
  def setup
    @biller = Biller.new("Aaron")
  end

  def test_that_I_am_the_biller
    assert_equal("Aaron Macy", @biller.name)
  end
end
