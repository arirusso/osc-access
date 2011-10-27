#!/usr/bin/env ruby

#
# Zeroconf support
#
# http://www.zeroconf.org
#
#

#
# much of this code was lifted from Zosc
# http://github.com/samBiotic/ruby-zosc
# Copyright (c) 2011 Sam Birkhead and released under the MIT License
#
#

require "dnssd"

module OSCAccess

  class ZeroconfService
    
    def initialize(name, port)
      @name, @port = name, port
      add
    end
    
    private
        
    def add
      zeroconf_registrar = Thread.new do
        registrar = DNSSD::Service.new
        registrar.register @name, '_osc._udp', nil, @port, do |r|
        end
      end
    end
      
  end

end
