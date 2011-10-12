#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-object"

class Instrument
  
  include OSCObject

  attr_accessor :pitch, :velocity
      
  osc_map("/1/fader1", :from => 0..1, :to => 0..127, :method => :pitch=)
  
  osc_map("/2/fader2", :from => 0..1, :to => 0..127) do |subject, value|
    p value
    subject.velocity = value
  end
  
end

Instrument.new(:join => true)