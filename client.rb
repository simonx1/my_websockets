#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'eventmachine'
require 'web_socket'

trap('INT') do
  EM.stop
  exit
end

EventMachine.run do

  # Connects to Web Socket server at host example.com port 10081.
  client = WebSocket.new("ws://localhost:1111")

  EventMachine.add_periodic_timer(1) do
    data = client.receive()
    puts data unless data.nil?
  end

  Thread.new {
  loop do
    print "Enter message: \n"
    line = readline
    client.send line
  end
  }

end
