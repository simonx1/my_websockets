require 'rubygems'
require 'eventmachine'
require 'faye/websocket'
require 'json'

trap('INT') do
  EM.stop
end


EventMachine.run do
  url = "ws://localhost:1111/"
  socket = Faye::WebSocket::Client.new(url)
  
  puts "Connecting to #{socket.url}"
  
  socket.onopen = lambda do |event|
    p [:open]
    socket.send({msg: "Hello, WebSocket!"}.to_json)
  end
  
  socket.onmessage = lambda do |event|
    p [:message, JSON.parse(event.data)]
    # socket.close 1002, 'Going away'
  end
  
  socket.onclose = lambda do |event|
    p [:close, event.code, event.reason]
    EM.stop
  end

end
