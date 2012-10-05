#!/usr/bin/env ruby
# encoding: utf-8
lib = File.expand_path('../daemon_market', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'eventmachine'
require 'logger'
require 'amqp'

require 'bank'
require 'account'

@logger = Logger.new(STDOUT)

@bank = DaemonMarket::Bank.new(accounts: {
  buyer_1: DaemonMarket::Account.new(pin: 1234, id: 'buyer_1', money: 100 ),
  seller_1: DaemonMarket::Account.new(pin: 1234, id: 'seller_1', money: 100 )
} )

EventMachine.run do

  @logger.info "Started bank with #{@bank.accounts.collect { |id, acc| "#{id}: #{acc.money}" }.join('; ')}"

  on_exit_signal = Proc.new do
    @logger.info "Closing connections..."
    AMQP.channel.connection.close do
      EventMachine.stop
      @logger.info "Main event loop stopped."
    end
  end

  Signal.trap "INT",  on_exit_signal
  Signal.trap "TERM", on_exit_signal

end
