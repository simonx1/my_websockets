require 'rubygems'
require 'em-websocket'

trap('INT') do
  EM.stop
end

EventMachine.run {
    puts "Statring server on port 1111. You can talk now."
    @channel = EM::Channel.new
 
    EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 1111) do |ws|

      ws.onerror { |error|
        if error.kind_of?(EM::WebSocket::WebSocketError)
          puts "Something went wrong: #{error.message}"
        end
      }

      ws.onopen {
        puts "WebSocket connection open"
        
        sid = @channel.subscribe { |msg| ws.send msg }
        nfo = "#{sid} connected!"
        puts nfo
        @channel.push nfo       

        ws.onclose {
          puts "Connection closed #{sid}"
          @channel.unsubscribe(sid)
        }
        ws.onmessage { |msg|
          puts "Recieved message: #{msg}"
          @channel.push "<#{sid}>: #{msg}"
        }
     }
  
    end
}
