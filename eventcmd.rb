#!/usr/bin/env ruby

# This program is run by pianobar each time an event occurs.
# It passes in an event string through STDIN.
#
# Rather than place the logic here, we'll dump the string to
# a socket for the main program to read!
#
# Here's all the fields passed in a typical event string (that we care about!!):
# artist:          current song's artist
# title:           name of current song
# album:           album the current song is from
# coverArt:        URL to a coverart image
# stationName:     the name of the station
# songStationName: TODO: figure out what this is...
# rating:          either 0 or 1 depending on whether you've liked the song
# detailUrl:       URL to pandora w/ information about the artist
# stationCount:    the number of stations you have
# stationX:        (where X is the station number) station name

require 'socket'
event = STDIN.read

sock = TCPSocket.new('localhost', 8000)
sock.write("#{event}\n\r")
sock.close

