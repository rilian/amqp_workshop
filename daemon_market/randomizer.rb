require 'account'

module DaemonMarket
  class Randomizer
    ITEMS = %w{sulphur souls magma tridents apples}

    def self.random_list
      items = ITEMS.sample(3)
      items.inject({}) { |res, item| res[item.to_sym] = rand(100).to_i; res }
    end
  end
end
