#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

class Instrument
  
  include OSCObject::Node
  
  osc_port :receive => 8000, :send => 9000
      
  osc_accessor :pitch, 
               :pattern => "/1/fader1", 
               :range => { :remote => 0..1, :local => 0..127 }
  #osc_writer :pulse_width, :pattern => "/1/fader2"
  
  #attr_osc :velocity, :pattern => "/1/rotary1", :range => 0..127
  
end

Instrument.new(:join => true)