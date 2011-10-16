#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

map = {
  :pitch => {
    :pattern => "/1/fader1", 
    :range => { :remote => 0..1, :local => 0..127 }
  }
  :velocity => {
    :type => :accessor,
    :pattern => "/1/fader2",
    :range => { :local => -24..24 }
  }
}
  
class Instrument
  
  include OSCAccessible
  
  attr_accessor :pitch, :velocity
      
end

i = Instrument.new
i.osc_start(:map => map).join
