#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

# this example demonstrates using the osc_receive class method
# to set the velocity accessor on Instrument instances

class Instrument
  
  include OSCAccessible

  osc_receive("/1/fader1", :accessor => :velocity, :translate => { :remote => 0..1, :local => 0..127 })
  
  def velocity=(val)
    puts "setting velocity to #{val}"
  end
  
end

i = Instrument.new
i.osc_start(:input_port => 8000).join