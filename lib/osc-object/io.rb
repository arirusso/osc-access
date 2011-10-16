#!/usr/bin/env ruby
module OSCObject
  
  class IO
    
    extend Forwardable
    
    attr_reader :thread
    def_delegators :thread, :join, :exit
    
    def initialize(target_obj, port_spec, options = {})
      @server = self.class.server(port_spec.receive)
      @client = self.class.client(options[:send_ip], ports_spec.transmit) unless options[:send_ip].nil?
    end
    
    def transmit(*a)
      @client.send(*a) unless @client.nil?
    end

    def receive(target_obj, pattern, &block)
      @server.add_method(pattern) { |message| yield(target_obj, message) }
    end

    def start
      @thread = Thread.new do
        Thread.abort_on_exception = true
        @server.run
      end
    end
    
    def self.server(port)
      @servers ||= {}
      @servers[port] ||= OSC::EMServer.new(port) 
      @servers[port]
    end
    
    def self.client(ip, port)
      @clients ||= {}
      @clients[ip] ||= {}
      @clients[ip][port] ||= OSC::Client.new(ip, port)
      @clients[ip][port]
    end

  end

end
