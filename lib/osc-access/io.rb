#!/usr/bin/env ruby
module OSCAccess

  class IO
        
    attr_reader :clients, :servers, :threads
    
    def initialize(options = {})
      @clients, @receivers, @servers = [], [], [], []
      @threads = {}
      @cached_message = nil
    end
    
    def join
      @threads.values.last.join
    end
    
    def add_server(port)
      pair = self.class.server(port)
      server = pair[:server]
      thread = pair[:thread]
      @servers << server
      @receivers.each { |receiver| add_method(server, receiver) }
      @threads[port] = thread
      thread
    end
    
    def add_method(server, receiver)
      options = receiver[:options]
      obj = receiver[:target_obj]
      pattern = receiver[:pattern].dup
      # this prevents the same action being called multiple times when
      # an IO object has multiple servers
      server.add_method(pattern) do |message| 
        unless @cached_message === message
          obj.send(:osc_on_receive, message, options, &receiver[:action]) 
          @cached_message = message
        end
      end
    end
    
    def add_client(host, port)
      @clients << self.class.client(host, port)
    end
    
    def transmit(*a)
      @clients.each { |c| c.send(*a) }
    end
    
    def self.start
      @servers.each do |port, server|
        @threads[port] ||= Thread.new do
          Thread.abort_on_exception = true
          @servers[port].run
        end
      end
    end

    def receive(target_obj, pattern, options = {}, &block)
      receiver = { 
        :target_obj => target_obj, 
        :pattern => pattern, 
        :options => options, 
        :action => block 
      }
      @receivers << receiver
      @servers.each { |server| add_method(server, receiver) }     
    end

    def self.server(port)
      @servers ||= {}
      @servers[port] ||= OSC::EMServer.new(port) 
      @threads ||= {}
      { :server => @servers[port], :thread => @threads[port] }
    end
    
    def self.client(host, port)
      @clients ||= {}
      @clients[host] ||= {}
      @clients[host][port] ||= OSC::Client.new(host, port)
      @clients[host][port]
    end

  end

end
