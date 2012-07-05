#!/usr/bin/env ruby

# pianobar.rb
# Provides a nice easy (maybe?) interface to pianobar.


class Pianobar
  # The different commands pianobar takes mapped out
  CONTROLS = {
    :next_song      => 'n',
    :pause          => 'p',
    :change_station => 's',
    :love_song      => '+',
    :ban_song       => '-'
  }
  
  # For ease of interaction we want to create a method for
  # each different control. Metaprogramming time!
  CONTROLS.each do |name,val|
    send :define_method, name do
      send_command(val)
    end
  end

  def send_command(com)
    `echo '#{com}' > /tmp/pianobar`
  end

  def initialize
    # Create fifo if it doesn't exist
    `mkfifo /tmp/pianobar`
    
    # Start pianobar, kill its output!
    `pianobar > /dev/null&`
  end
  
  # When eventcmd.rb barfs out an event, parse it into a hash
  def self.parse_event(event)
    fields = event.split("\n")
    return nil unless fields
    fields.map! { |f| f.split('=') }
    
    # Remove all the empty fields, they'll end up nil anyways
    fields.reject! { |f| f.length != 2 }
    
    # Create a hash, and fill it
    # Field names are all symbols
    result = {}
    fields.each { |f| result[f[0].to_sym] = f[1] }
    
    return result
  end
  
  # Given the event hash, returns an array of station names
  def self.parse_stations(event)
    return nil unless event[:stationCount]
    num = event[:stationCount].to_i
    return nil unless num
    stations = []
    
    (0..(num-1)).each do |i|
      name = "station#{i}".to_sym
      stations << event[name]
    end
    
    return stations
  end
end
