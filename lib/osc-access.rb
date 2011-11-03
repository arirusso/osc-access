#!/usr/bin/env ruby
#
# OSCAccess
# Control Ruby objects with OSC
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "osc-ruby"
require "osc-ruby/em_server"

# modules
require "osc-access/accessible"
require "osc-access/class"

# classes
require "osc-access/class_scheme"
require "osc-access/emittable_property"
require "osc-access/emitter"
require "osc-access/message"
require "osc-access/receiver"
require "osc-access/translate"
require "osc-access/zeroconf"

# other
require "osc-access/default"

module OSCAccess
  
  VERSION = "0.0.11"
  
end
OSCAccessible = OSCAccess::Accessible