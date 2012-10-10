require 'rubygems'
require 'eventmachine'
require 'em-websocket'
require 'json'

@sockets = {}

puts "Starting server on port 1111"

EventMachine.run do

  EventMachine::WebSocket.start(host: '0.0.0.0', port: 1111) do |socket|

    EventMachine.add_periodic_timer(10) do
      @sockets.each { |id, s|
        s.send({ msg: "ping"}.to_json)
      }
    end
 
    socket.onopen do
      @sockets.merge!(socket.object_id => socket)
      puts "Opened socket with id: #{socket.object_id}"
      socket.send({ msg: "Hello #{socket.object_id}!"}.to_json)
      status
    end

    socket.onmessage do |msg|
      js_msg = JSON.parse(msg)['msg']
      puts "Message '#{js_msg}' received" 
      socket.send({ msg: "Pong: #{msg.strip}"}.to_json)
    end

    socket.onclose do
      @sockets.delete socket.object_id
      puts "Socket id: '#{socket.object_id}' has gone!"
      status
    end

    def status
      puts "Number of sockets registered: #{@sockets.count}."
    end

  end
end

