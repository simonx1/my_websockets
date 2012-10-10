require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'json'

@sockets = {}

EventMachine.run do

  puts "Statring server on port 1111. You can talk now."
  @status_channel = EM::Channel.new

  EventMachine::WebSocket.start(host: '0.0.0.0', port: 1111) do |socket|

    EventMachine.add_periodic_timer(10) do
      @status_channel.push({ status: 'check'}.to_json)
    end
 
    socket.onopen do
      sid = @status_channel.subscribe { |msg| socket.send msg }
      @sockets.merge!(sid => socket)
      puts "Opened socket with id: #{sid}"
      socket.send({ msg: "Hello #{sid}!"}.to_json)
      status
    end

    socket.onmessage do |msg|
      js_msg = JSON.parse(msg)
      puts "Message '#{js_msg['msg']}' received" 
      socket.send({ msg: "Pong: #{js_msg['msg']}"}.to_json)
    end

    socket.onclose do
      sid = @sockets.key(socket)
      @sockets.delete sid
      @status_channel.unsubscribe(sid)
      puts "Socket id: '#{sid}' has gone!"
      status
    end

    def status
      puts "Number of sockets registered: #{@sockets.count}."
    end

  end
end

