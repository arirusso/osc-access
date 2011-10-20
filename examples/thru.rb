#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "osc-access"

# this example relays all messages from the input to the output

# notice that the :thru option is set to true on osc_receive

class Instrument
  
  include OSCAccessible

  osc_receive(/.*/, :thru => true)
  
end

i = Instrument.new
i.osc_start(:input_port => 8000, :output => { :host => "192.168.1.4", :port => 9000 }).join