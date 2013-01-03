module Models
  def db
    INVOICES_DB
  end
  def create_billers_table
    db.execute <<-SQL
      create table billers (
        name varchar(30),
        street1 varchar(30),
        street2 varchar(30),
        city varchar(30),
        state varchar(2),
        zip varchar(5),
        phone varchar(14)
      );
    SQL
  end
  def add_row_to_billers_table(biller)
    db.execute("INSERT INTO billers 
               (name, street1, street2, city, state, zip, phone) 
               VALUES (?, ?, ?, ?, ?, ?, ?)", 
               [biller.name, biller.street1, biller.street2, biller.city, biller.state, biller.zip, biller.phone])
  end
  def create_clients_table
    db.execute <<-SQL
      create table clients (
        name varchar(30),
        street1 varchar(30),
        street2 varchar(30),
        city varchar(30),
        state varchar(2),
        zip varchar(5),
        phone varchar(14),
        rate int
      );
    SQL
  end
  def add_row_to_clients_table(client)
    db.execute("INSERT INTO clients 
               (name, street1, street2, city, state, 
               zip, phone, rate) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
               [client.name, client.street1, client.street2, client.city, client.state, client.zip, client.phone, client.rate])
  end
  def create_invoices_table
    db.execute <<-SQL
      create table invoices (
        invoice_number int,
        date varchar(10),
        client_id int,
        total_hrs int,
        total_cost int
        );
    SQL
  end
  def calculate_total_hrs(invoice)
    invoice.total_hrs = 0
    invoice.line_items_array.each do |line_item|
      invoice.total_hrs += line_item.hrs
    end
    invoice.total_hrs
  end
  def calculate_total_cost(invoice)
    invoice.total_cost = 0
    invoice.line_items_array.each do |line_item|
      invoice.total_cost += line_item.cost
    end
    invoice.total_cost
  end
  def add_row_to_invoices_table(invoice)
    db.execute("INSERT INTO invoices 
               (invoice_number, date, client_id, total_hrs, total_cost) 
               VALUES (?, ?, ?, ?, ?)", 
               [invoice.calculate_number, invoice.date, invoice.client_id, calculate_total_hrs(invoice), calculate_total_cost(invoice)])
  end
  def create_line_items_table
    db.execute <<-SQL
      create table line_items (
        invoice_number int,
        line_number int,
        commit_date varchar(10),
        commit_msg varchar,
        hrs int,
        rate int,
        cost int
        );
    SQL
  end
  def add_row_to_line_items_table(item)
    db.execute("INSERT INTO line_items 
           (invoice_number, line_number, commit_date, commit_msg, hrs, rate, cost) 
           VALUES (?, ?, ?, ?, ?, ?, ?)", 
           [item.invoice_number, item.line_number, item.date, item.msg, item.hrs, item.rate, item.cost])
  end
end
