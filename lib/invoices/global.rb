INVOICES_VERSION = '0.1.0'
INVOICES_FOLDER = File.expand_path('~/Invoices')
INVOICES_DB = SQLite3::Database.new('db/invoices.db')
TEST_DB = SQLite3::Database.new('db/test.db')

def choose_db(*boolean)
  if boolean.first
    TEST_DB
  else
    INVOICES_DB
  end
end
