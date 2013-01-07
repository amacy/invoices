class Schema
  def initialize(database)
    @database = database
    create_all
  end
  def create_all
    create_billers_table
    create_clients_table
    create_invoices_table
    create_line_items_table
  end
  def create_billers_table
    @database.execute <<-SQL
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
  def create_clients_table
    @database.execute <<-SQL
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
  def create_invoices_table
    @database.execute <<-SQL
      create table invoices (
        invoice_number int,
        date varchar(10),
        client_id int,
        total_hrs int,
        total_cost int
        );
    SQL
  end
  def create_line_items_table
    @database.execute <<-SQL
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
end
