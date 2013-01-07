INVOICES_VERSION = '0.0.0'
INVOICES_FOLDER = File.expand_path('~/Invoices')
INVOICES_DB = SQLite3::Database.new('db/invoices.db')
def db
  INVOICES_DB
end
TEST_DB = SQLite3::Database.new('db/test.db')
