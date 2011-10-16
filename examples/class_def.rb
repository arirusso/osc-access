#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

class Instrument
  
  include OSCAccessible
  
  osc_accessor :pitch, 
               :pattern => "/1/fader1", 
               :range => { :remote => 0..1, :local => 0..127 }
  #osc_writer :pulse_width, :pattern => "/1/fader2"
  
  #attr_osc :velocity, :pattern => "/1/rotary1", :range => 0..127
  
end

i = Instrument.new
i.osc_start.join