#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

class Instrument
  
  include OSCObject
      
  osc_accessor :pitch, :pattern => "/1/fader1", :range => { :osc => 0..1, :property => 0..127 }, :return => :value
  osc_writer :pulse_width, :pattern => "/1/fader2"
  
  #attr_osc :velocity, :pattern => "/1/rotary1", :range => 0..127
  
end

Instrument.new(:join => true)