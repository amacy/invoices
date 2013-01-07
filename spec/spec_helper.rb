require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require 'sqlite3'
require_relative '../db/schema'
require_relative '../lib/invoices/global'

Schema.new(TEST_DB) unless File.exists?('db/test.db')
