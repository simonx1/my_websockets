require 'rubygems'
require 'eventmachine'
require 'em-websocket'

@sockets = {}

puts "Starting server on port 1111"

EventMachine.run do

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 1111) do |socket|
 
    socket.onopen do
      @sockets.merge(socket.object_id => socket)
      puts "Opened socket with id: #{socket.object_id}"
      socket.send "Hello #{socket.object_id}!"
    end
    socket.onmessage do |msg|
      puts "Message '#{msg.strip}' received"
      @sockets.each {|id, s| s.send msg}
      socket.send "Pong: #{msg.strip}"
    end
    socket.onclose do
      @sockets.delete socket.object_id
    end


  end
end

