#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# this example shows accepting OSC messages on 10 input ports

# you can assign ports as such using a range, an array of numbers or a single number

require "osc-access"

class Instrument
  
  include OSCAccessible

  osc_receive("/1/fader1", :translate => { :remote => 0..1, :local => 0..127 }) do |instance, val|
    instance.velocity = val
  end
  
  def velocity=(val)
    puts "setting velocity to #{val}"
  end
  
end

i = Instrument.new
i.osc_start(:input_port => 8000..8009).join
