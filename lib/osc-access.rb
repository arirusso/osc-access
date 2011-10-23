#!/usr/bin/env ruby
#
# OSCAccess
# Control Ruby object with OSC
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "osc-ruby"
require "osc-ruby/em_server"

# modules
require "osc-access/accessible"
require "osc-access/class"

# classes
require "osc-access/analog"
require "osc-access/class_scheme"
require "osc-access/io"
require "osc-access/message"

# other
require "osc-access/default"

module OSCAccess
  
  VERSION = "0.0.4"
  
end
OSCAccessible = OSCAccess::Accessible