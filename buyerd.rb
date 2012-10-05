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
@buyer_id = 'buyer_1'

EventMachine.run do

  @logger.info "Started buyer #{@buyer.account.id} wanting to buy #{@buyer.list.inspect}"

  AMQP.start("amqp://guest:guest@192.168.1.130/dima") do |connection|
    @connection = connection

    channel = AMQP::Channel.new(@connection)

    market_ex = channel.topic("market", auto_delete: true)

    market_q = channel.queue("market.#{@buyer_id}") do |queue|
      queue.bind(market_ex, routing_key: "market.ads.#").subscribe do |metadata, payload|
        @logger.info("Got #{payload} with metadata")
      end
    end
  end

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
