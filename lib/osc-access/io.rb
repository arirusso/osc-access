#!/usr/bin/env ruby
module OSCAccess
  
  class IO
    
    attr_reader :clients, :servers, :threads
    
    def initialize(options = {})
      @clients, @servers = [], []
      @threads = {}
      input_port = options[:input_port] || DefaultInputPort
      add_server(input_port) 
      unless options[:output].nil?
        output_port = options[:output][:port] || DefaultOutputPort
        add_client(options[:output][:host], output_port) 
      end
    end
    
    def join
      @threads.values.last.join
    end
    
    def add_server(port)
      server = self.class.server(port)
      @servers << server
      @threads[server] = Thread.new do
        Thread.abort_on_exception = true
        server.run
      end      
    end
    
    def add_client(host, port)
      @clients << self.class.client(host, port)
    end
    
    def transmit(*a)
      @clients.each { |c| c.send(*a) }
    end

    def receive(target_obj, pattern, &block)
      @servers.each do |server|
        server.add_method(pattern) { |message| yield(target_obj, message) }
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
