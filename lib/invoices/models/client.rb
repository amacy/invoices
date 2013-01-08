class Client
  attr_accessor :id, :name, :street1, :street2, :city, 
                :state, :zip, :phone, :rate#, :email
  def find_by_name(name, *boolean)
    client = choose_db(*boolean).execute("select * from clients 
                        where name = '#{name}'").first
    @id = choose_db(*boolean).execute("select rowid from clients 
                     where name = '#{name}'").first
    @name = client[0].to_s
    @street1 = client[1].to_s
    @street2 = client[2].to_s
    @city = client[3].to_s
    @state = client[4].to_s
    @zip = client[5].to_s
    @phone = client[6].to_s
    #@email = client[].to_s
    @rate = client[7]
    return self
  end
  def save(*boolean)
    choose_db(*boolean).execute("INSERT INTO clients 
               (name, street1, street2, city, state, 
               zip, phone, rate) 
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)", 
               [@name, @street1, @street2, @city, @state, @zip, @phone, @rate])
  end
end
