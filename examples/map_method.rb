#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

class Instrument
  
  include OSCObject
      
  attr_osc :pitch, :pattern => "/1/fader1", :range => { :input => 0..1, :output => 0..127 }
  
  attr_osc :pulse_width, :pattern => "/2/fader2"
  
  attr_osc :velocity, :pattern => "/2/fader2", :range => 0..127
  
end

Instrument.new(:join => true)