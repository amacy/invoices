INVOICES_VERSION = '0.2.0'
INVOICES_FOLDER = File.expand_path('~/Invoices')
INVOICES_DB = SQLite3::Database.new('db/invoices.db')
TEST_DB = SQLite3::Database.new('db/test.db')

def choose_db(*boolean)
  boolean.first ? TEST_DB : INVOICES_DB
end
