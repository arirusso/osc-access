#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

class Instrument
  
  include OSCObject
  
  # uncomment the following line if you don't want to receive messages on port 8000
  # osc_receive_port 9000
  
  attr_accessor :pitch
      
  receive_osc "/1/fader1" do |subject, msg|
    
    analog(msg.args.first, :from => 0..1, :to => 0..127) do |val|
      p "setting pitch to #{val}"
      subject.pitch = val
    end
    
  end
  
  def initialize
    start_receiving_osc.join
  end
  
end

Instrument.new