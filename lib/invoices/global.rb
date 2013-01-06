INVOICES_VERSION = '0.0.0'
INVOICES_FOLDER = File.expand_path('~/Invoices')
INVOICES_DB = SQLite3::Database.new('invoices.db')
def db
  INVOICES_DB
end
