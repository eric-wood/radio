#!/usr/bin/env ruby

require 'socket'
require 'serialport'
require_relative 'pianobar.rb'

# radio.rb
# Here lies the main program!
# From here we'll be abstracting the controls on the radio and the pandora
# interface using the accompanying programs. Hooray!
    
# Start listening on port 8000 for events!
@server = TCPServer.new(8000)

# Open serial connection to arduino
@serial = SerialPort.new('/dev/tty.usbserial-A9007PWI', 9600)

begin
  @pb = Pianobar.new

  # Select the first station, just 'cause
  # TODO: change this maybe? meh.
  @pb.select_station(0)

  trap('SIGINT') do
    # TODO: maybe in the future just kill the pianobar process we started?
    `killall pianobar`
    exit!
  end

  reads = [@server, @serial]
  clients = []
  loop do
    io = IO.select(reads + clients, [])
    io[0].each do |fd|
      if fd == @server
        client = @server.accept
        clients << client
      elsif fd == @serial
        data = @serial.readline
        level = data.to_f * (16.to_f/1024)
        puts data
        puts level
        `osascript -e 'set volume #{level/2}'`
      elsif clients.include?(fd)
        raw_event = fd.gets("\n\r")
        event = Pianobar.parse_event(raw_event)
        stations = Pianobar.parse_stations(event)
        clients.delete(fd)
        fd.close
        p event
      elsif fd.eof?
        clients.delete(fd)
      end
    end
  end
rescue => e
  `killall pianobar`
  raise e
end
