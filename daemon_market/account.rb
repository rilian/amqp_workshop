module DaemonMarket
  class Account
    # ID in bank
    attr_accessor :id

    # Amount of money
    def money
      @money || 0
    end

    # Pin code
    attr_accessor :pin

    def initialize(opts={})
      @id     = opts[:id]
      @money  = opts[:money]
      @pin    = opts[:pin]
    end

    def update(m)
      @money = m
    end

    def withdraw(m)
      raise "Unable to withdraw #{m} from #{money}" if ( money - m < 0 )
      @money = money - m
    end

    def put(m)
      @money = money + m
    end
  end
end
