#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

map = {
  "/1/fader1" => { 
    :proc => Proc.new do |instance, msg| 
      instance.pitch = instance.osc_translate(msg.args.first, :remote => 0..1, :local => 0..127)
      instance.osc_send(msg)
    end
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
