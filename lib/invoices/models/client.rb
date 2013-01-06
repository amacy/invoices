class Client
  attr_accessor :id, :name, :street1, :street2, :city, 
                :state, :zip, :phone, :rate
  def initialize(name)
    if name.empty?
    else
      client = db.execute("select * from clients 
                          where name = '#{name}'").first
      @id = db.execute("select rowid from clients 
                       where name = '#{name}'").first
      @name = client[0].to_s
      @street1 = client[1].to_s
      @street2 = client[2].to_s
      @city = client[3].to_s
      @state = client[4].to_s
      @zip = client[5].to_s
      @phone = client[6].to_s
      @rate = client[7].to_s
    end
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
end
