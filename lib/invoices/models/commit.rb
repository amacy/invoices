class Commit

  attr_accessor :date, :msg

  def initialize(line)
    parse_date(line)
    parse_msg(line)
  end

  private

    def parse_date(line)
      timestamp = line.split(/> /).last.slice(0, 10).to_i
      @date = Time.at(timestamp) # Convert Unix timestamp
    end

    def parse_msg(line)
      if line.include?("commit:")
        @msg = line.split(/commit:/).last.strip.slice(0, 40)
      elsif line.include?("commit (initial):")
        @msg = line.split(/commit \(initial\):/).last.strip.slice(0, 40)
      end
    end
end
