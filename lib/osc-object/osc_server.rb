#!/usr/bin/env ruby
module OSCObject
  
  class OSCServer
    
    attr_reader :port
    
    def initialize(instrument, port, options = {})
      @running = false
      @server = OSC::EMServer.new( port )
      self.class.servers << self
    end
    
    def start(options = {})
      background = options[:background] === true
      if background
        @thread = Thread.new do
          @server.run 
        end
      else
        @server.run 
      end
      @running = true
    end
    
    def running? 
      @running
    end
    
    def stop(options = {})
      @thread.kill
      @running = false
    end
    
    def add_method(instrument, pattern, &block)
      @server.add_method(pattern) { |message| yield(instrument, message) }
    end
    
    class << self
      attr_reader :servers
    end
    
    def self.find(port)
      @servers ||= []
      @servers.find { |s| s.port == port }
    end
          
  end
  
end
