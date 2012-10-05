require 'account'

module DaemonMarket
  class Seller
    # An Account class instance
    attr_accessor :account

    # A storage for goods: {potatoes: 100, apples: 20}
    attr_accessor :store

    def initialize(opts={})
      @account = Account.new(opts[:account])
      @store   = opts[:store] || {}
    end

    # Tell about goods to sail
    def announce
      return false if store.empty?
      store.keys.sample(1).first
    end

    # Check if can sell amount of item
    def can_i_sell?(item, amount)
      (list[item.to_sym].to_i - amount >= 0)
    end

    def update_account(money)
      account.update(money)
    end

    # Remove item from store
    def remove_from_store(item, amount)
      store[item.to_sym] = store[item.to_sym].to_i - amount.to_i
      store.delete(item.to_sym) if store[item.to_sym] <= 0
    end
  end
end
