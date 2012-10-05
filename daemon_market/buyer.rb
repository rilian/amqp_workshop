require 'account'

module DaemonMarket
  class Buyer
    # An Account class instance
    attr_accessor :account

    # A cart with goods: {potatoes: 100, apples: 20}
    attr_accessor :cart

    # List for things to buy: {apples: 10}
    attr_accessor :list

    def initialize(opts={})
      @account = Account.new(opts[:account])
      @store   = opts[:store] || {}
      @list    = opts[:list]  || {}
    end

    # Check if we need to buy this item to
    def should_i_buy?(item)
      !!list[item.to_sym]
    end

    def can_i_buy?(item, price, amount)
      should_i_buy? &&
        ( list[item.to_sym].to_i -  amount.to_i >= 0 ) &&
        ( amount.to_i * price < account.money )
    end

    def update_account(money)
      account.update(money)
    end

    # Put item to cart
    def put_to_cart(item, amount)
      cart[item.to_sym] = cart[item.to_sym].to_i + amount.to_i
      list[item.to_sym] = list[item.to_sym].to_i - amount.to_i
      list.delete(item.to_sym) if list[item.to_sym] <= 0
    end

  private
  end
end
