#!/usr/bin/env ruby
module OSCAccess
  
  class IO
    
    extend Forwardable
    
    attr_reader :client, :server, :thread
    def_delegators :thread, :join, :exit
    
    def initialize(target_obj, port_spec, options = {})
      @server = self.class.server(port_spec.receive)
      @client = self.class.client(options[:remote_host], port_spec.transmit) unless options[:remote_host].nil?
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
    
    def self.client(host, port)
      @clients ||= {}
      @clients[host] ||= {}
      @clients[host][port] ||= OSC::Client.new(host, port)
      @clients[host][port]
    end

  end

end
