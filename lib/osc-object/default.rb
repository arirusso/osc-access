#!/usr/bin/env ruby
module OSCObject
  
  DefaultPattern = /.*/
  DefaultPorts = PortSpec.new({ :receive => 8000, :transmit => 9000 })
  DefaultRemoteRange = 0..1

end
