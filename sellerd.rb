#!/usr/bin/env ruby
# encoding: utf-8
lib = File.expand_path('../daemon_market', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'eventmachine'
require 'logger'
require 'amqp'

require 'seller'
require 'randomizer'

@logger = Logger.new(STDOUT)
@seller = DaemonMarket::Seller.new(store: DaemonMarket::Randomizer.random_list, account: {pin: 1234, id: 'seller_1', money: 100 })

EventMachine.run do

  @logger.info "Started seller #{@seller.account.id} with #{@seller.store.inspect}"

  on_exit_signal = Proc.new do
    @logger.info "Closing connections..."
    @connection.close do
      EventMachine.stop
      @logger.info "Main event loop stopped."
    end
  end

  Signal.trap "INT",  on_exit_signal
  Signal.trap "TERM", on_exit_signal

end
