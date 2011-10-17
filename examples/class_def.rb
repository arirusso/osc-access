#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

class Instrument
  
  include OSCAccessible

  osc_receive "/1/fader1" do |instance, msg|
    val = instance.osc_translate(msg.args.first, :local => 0..127, :remote => 0..1 )
    instance.velocity = val
  end
  
  def velocity=(val)
    puts "setting velocity to #{val}"
  end
  
end

i = Instrument.new
i.osc_start(:input_port => 8000).join