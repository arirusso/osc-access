#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

map = {
  "/1/fader1" => { 
    :proc => Proc.new do |instance, msg| 
      instance.pitch = osc_analog(msg.args.first, :range => { :remote => 0..1, :local => 0..127 })
      instance.osc_send(msg)
    end
  }
}
  
class Instrument
  
  include OSCAccessible
  
  attr_accessor :pitch, :velocity

end

i = Instrument.new
i.osc_start(:map => map).join
