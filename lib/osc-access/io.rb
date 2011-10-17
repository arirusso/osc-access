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
      @receivers.each { |receiver| add_method(server, receiver) }
      @threads[server] = thread
      thread
    end
    
    def add_method(server, receiver)
      options = receiver[:options]
      obj = receiver[:target_obj]
      server.add_method(receiver[:pattern].dup) { |message| obj.send(:osc_on_receive, message, options, &receiver[:proc]) }
    end
    
    def add_client(host, port)
      @clients << self.class.client(host, port)
    end
    
    def transmit(*a)
      @clients.each { |c| c.send(*a) }
    end

    def receive(target_obj, pattern, options = {}, &block)
      receiver = { 
        :target_obj => target_obj, 
        :pattern => pattern, 
        :options => options, 
        :proc => block 
      }
      @receivers << receiver
      @servers.each { |server| add_method(server, receiver) }     
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
