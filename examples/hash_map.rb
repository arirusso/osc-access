#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

map = {
  "/1/fader1" => { 
    :translate => { :remote => 0..1, :local => 0..127 },
    :action => Proc.new { |instance, val| instance.pitch = val }
  }
}
  
class Instrument
  
  include OSCAccessible
  
  def pitch=(val)
    p "setting pitch to #{val}"
  end

end

i = Instrument.new
i.osc_start(:map => map, :input_port => 8000).join
