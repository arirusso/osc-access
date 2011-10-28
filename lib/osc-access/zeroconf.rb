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
  
  module Zeroconf

    class Service
    
      def initialize(name, port)
        @name, @port = name, port
      end
        
      def start
        @thread = Thread.new do
          registrar = DNSSD::Service.new
          registrar.register @name, '_osc._udp', nil, @port, do |r|
          end
        end
        self
      end
    
      def stop
        @thread.kill unless @thread.nil?
        self
      end
    
    end
      
  end

end
