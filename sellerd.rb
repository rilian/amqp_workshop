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
@seller_id = 'seller_1'

EventMachine.run do

  @logger.info "Started seller #{@seller.account.id} with #{@seller.store.inspect}"

  AMQP.start("amqp://guest:guest@192.168.1.130/dima") do |connection|
    @connection = connection

    channel = AMQP::Channel.new(@connection)

    market_ex = channel.topic("market", auto_delete: true)

    10.times do
      market_ex.publish(@seller.announce, routing_key: "market.ads.#{@seller_id}")
    end

  end

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
