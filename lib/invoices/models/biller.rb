class Biller
  attr_accessor :name, :street1, :street2, :city, 
                :state, :zip, :phone
  def initialize(param)
    if param.empty?
    else
      biller = db.execute("select * from billers").first
      @name = biller[0].to_s
      @street1 = biller[1].to_s
      @street2 = biller[2].to_s
      @city = biller[3].to_s
      @state = biller[4].to_s
      @zip = biller[5].to_s
      @phone = biller[6].to_s
    end
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
end
