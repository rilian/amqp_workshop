module DaemonMarket
  class Bank
    # Accounts
    attr_accessor :accounts

    # Transactions
    attr_accessor :transactions

    def initialize(opts={})
      @accounts = opts[:accounts] || []
      @transactions = {}
    end

    def transfer(from, to, amount, pin)
      return false unless valid_pin?(from, pin)

      old_from = accounts[from].money
      pld_to   = accounts[to].money

      accounts[from].withdraw(amount)
      accounts[to].put(amount)

      transaction_id = random(Time.now.to_i)
      transactions[transaction_id] = {
          from: from,
          to:   to,
          amount: amount,
          at:   Time.now
        }

      transaction_id
    rescue => e
      accounts[from].update(old_from)
      accounts[to].update(old_to)
      transactions.delete(transaction_id)
      raise e
    end

    def transaction_exists?(transaction_id)
      !!transactions[transaction_id]
    end

    def valid_pin?(account_id, pin)
      accounts[account_id].pin == pin
    end

  end
end
