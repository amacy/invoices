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
  def save
    # Should raise error unless all fields except for street2 are filled
    db.execute("INSERT INTO billers 
               (name, street1, street2, city, state, zip, phone) 
               VALUES (?, ?, ?, ?, ?, ?, ?)", 
               [@name, @street1, @street2, @city, @state, @zip, @phone])
  end
end
