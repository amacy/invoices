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
  def add_row_to_billers_table(name, street1, street2, city, state, zip, phone)
    db.execute("INSERT INTO billers 
               (name, street1, street2, city, state, zip, phone) 
               VALUES (?, ?, ?, ?, ?, ?, ?)", 
               [name, street1, street2, city, state, zip, phone])
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
               (name, street1, street2, city, state, zip, phone, rate) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
               [client.name, client.street1, client.street2, client.city, client.state, client.zip, client.phone, client.rate])
  end
  def create_invoices_table
    db.execute <<-SQL
      create table invoices (
        invoice_number int,
        date varchar(10),
        biller_id int,
        client_id int
        );
    SQL
  end
  def add_row_to_invoices_table(num, date, client_id)
    db.execute("INSERT INTO invoices 
               (invoice_number, date, client_id) 
               VALUES (?, ?, ?)", 
               [num, date, client_id])
  end
  def create_line_items_table
    db.execute <<-SQL
      create table line_items (
        invoice_number int,
        line_number int,
        commit_date varchar(10),
        commit_msg varchar,
        hrs int,
        rate int
        );
    SQL
  end
  def add_row_to_line_items_table(invoice_num, line_num, commit_date, commit_msg, hrs, rate)
    db.execute("INSERT INTO line_items 
           (invoice_number, line_number, commit_date, commit_msg, hrs, rate) 
           VALUES (?, ?, ?, ?, ?, ?)", 
           [invoice_num, line_num, commit_date, commit_msg, hrs, rate])
  end
end
