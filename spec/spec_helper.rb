require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require 'sqlite3'
require_relative '../db/schema'
require_relative '../lib/invoices/global'

Schema.new.create_all_tables(TEST_DB)
