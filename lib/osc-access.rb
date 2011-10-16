#!/usr/bin/env ruby
#
# OSCAccess
# Control Ruby object with OSC
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"

require "osc-ruby"
require "osc-ruby/em_server"

# modules
require "osc-access/accessible"
require "osc-access/class"

# classes
require "osc-access/class_scheme"
require "osc-access/io"
require "osc-access/message"
require "osc-access/port_spec"
require "osc-access/range_analog"

# other
require "osc-access/default"

module OSCAccess
  
  VERSION = "0.0.1"
  
end
OSCAccessible = OSCAccess::Accessible