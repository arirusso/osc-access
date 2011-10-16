#!/usr/bin/env ruby
module OSCAccess
  
  class IO
    
    attr_reader :clients, :servers, :threads
    
    def initialize(options = {})
      @clients, @receivers, @servers = [], [], []
      @threads = {}
      initialize_node(options) 
    end
    
    def initialize_node(options = {})
      add_server(options[:input_port]) unless options[:input_port].nil?
      add_client(options[:output][:host], options[:output][:port]) unless options[:output].nil?
    end
    
    def join
      @threads.values.last.join
    end
    
    def add_server(port)
      pair = self.class.server(port)
      server = pair[:server]
      thread = pair[:thread]
      @servers << server
      @receivers.each do |receiver| 
        server.add_method(receiver[:pattern]) do |message| 
          receiver[:block].call(receiver[:target_obj], message)
        end
      end
      @threads[server] = thread
      thread
    end
    
    def add_client(host, port)
      @clients << self.class.client(host, port)
    end
    
    def transmit(*a)
      @clients.each { |c| c.send(*a) }
    end

    def receive(target_obj, pattern, &block)
      @receivers << { :target_obj => target_obj, :pattern => pattern, :block => block }
      @servers.each do |server|
        server.add_method(pattern) { |message| yield(target_obj, message) }
      end      
    end

    def self.server(port)
      @servers ||= {}
      @servers[port] ||= OSC::EMServer.new(port) 
      @threads ||= {}
      @threads[port] ||= Thread.new do
        Thread.abort_on_exception = true
        @servers[port].run
      end
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
