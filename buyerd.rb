#!/usr/bin/env ruby
# encoding: utf-8
lib = File.expand_path('../daemon_market', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'bundler/setup'
require 'eventmachine'
require 'logger'
require 'amqp'

require 'buyer'
require 'randomizer'

@logger = Logger.new(STDOUT)
@buyer = DaemonMarket::Buyer.new(list: DaemonMarket::Randomizer.random_list, account: {pin: 1234, id: 'buyer_1', money: 100 })

EventMachine.run do

  @logger.info "Started buyer #{@buyer.account.id} wanting to buy #{@buyer.list.inspect}"

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
