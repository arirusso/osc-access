#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

# this example demonstrates using a Hash map to set the input events

# you can pass the map to osc_start as such
# or you could call i.osc_load_map(map)

map = {
  "/1/fader1" => { 
    :translate => { :remote => 0..1, :local => 0..127 },
    :action => Proc.new { |instance, val| instance.pitch = val }
  }
  "/1/fader2" => { 
    :translate => { :remote => 0..1, :local => 0..127 },
    :action => Proc.new { |instance, val| instance.velocity = val }
  }
}
  
class Instrument
  
  include OSCAccessible
  
  def pitch=(val)
    p "setting pitch to #{val}"
  end
  
  def velocity=(val)
    p "setting velocity to #{val}"
  end

end

i = Instrument.new
i.osc_start(:map => map, :input_port => 8000).join
