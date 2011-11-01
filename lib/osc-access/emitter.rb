#!/usr/bin/env ruby
module OSCAccess

  class Emitter
    
    attr_reader :clients
    
    def initialize
      @clients = []
    end
       
    def add_client(host, port)
      @clients << self.class.client(host, port)
    end
    
    def transmit(*a)
      if a.first.kind_of?(OSC::Message)
        msg = a.pop
        transmit(*a) unless a.empty?
      else
        msg = OSC::Message.new(*a)
      end
      @clients.each { |c| c.send(msg) }
    end
    
    def self.client(host, port)
      @clients ||= {}
      @clients[host] ||= {}
      @clients[host][port] ||= OSC::Client.new(host, port)
      @clients[host][port]
    end
    
  end

end
