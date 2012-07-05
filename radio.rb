#!/usr/bin/env ruby

require 'socket'
require_relative 'pianobar.rb'

# radio.rb
# Here lies the main program!
# From here we'll be abstracting the controls on the radio and the pandora
# interface using the accompanying programs. Hooray!
    
# Start listening on port 8000 for events!
@server = TCPServer.new(8000)

@pb = Pianobar.new

# Select the first station, just 'cause
# TODO: change this maybe? meh.
@pb.select_station(0)

trap('SIGINT') do
  # TODO: maybe in the future just kill the pianobar process we started?
  `killall pianobar`
  exit!
end

loop do
  io = IO.select([@server], [])
  client = @server.accept
  raw_event = client.gets("\n\r")
  event = Pianobar.parse_event(raw_event)
  stations = Pianobar.parse_stations(event)
  client.close
  p event
end
