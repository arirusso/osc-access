#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

map = [
  { 
    :pattern => '/1/fader1',
    :to_range => (0..127),
    :property => :pitch=
  },
  { 
    :pattern => '/1/fader2',
    :to_range => (-24..24),
    :property => :velocity=
  }
]
  
class Instrument
  
  include OSCObject
  
  attr_accessor :pitch, :velocity
      
end

Instrument.new(:map => map, :join => true)
