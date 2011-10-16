#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

map = {
  :pitch => {
    :pattern => "/1/fader1", 
    :range => { :remote => 0..1, :local => 0..127 }
  },
  :velocity => {
    :type => :accessor,
    :pattern => "/1/fader2",
    :range => { :local => -24..24 }
  },
  "/1/button1" => { 
    :proc => Proc.new do |instance, msg| 
      instance.whatever=msg.args[0]
      instance.osc_send(msg)
    end
  }
}
  
class Instrument
  
  include OSCAccessible
  
  attr_accessor :pitch, :velocity
  
  def whatever=(what)
    p "hi from whatever"
  end
      
end

i = Instrument.new
i.osc_start(:map => map).join
