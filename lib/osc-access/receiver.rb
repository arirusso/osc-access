#!/usr/bin/env ruby
module OSCAccess

  class Receiver

    attr_reader :servers 
             
    def initialize(options = {})
      @receivers = []
      @servers = {}
      @cached_message = nil
    end
    
    def threads
      @servers.values.map { |server| server[:thread] }
    end
    
    def join(options = {})
      port = options[:port]
      thread = port.nil? ? threads.last : @servers[port][:thread]
      thread.join
    end
    
    def add_server(port)
      server = self.class.server(port)
      @servers[port] = server
      @receivers.each { |receiver| add_method(server[:server], receiver) }
      @servers[port][:thread]
    end
    
    def add_receiver(target_obj, pattern, options = {}, &block)
      receiver = { 
        :target_obj => target_obj, 
        :pattern => pattern, 
        :options => options, 
        :action => block 
      }
      @receivers << receiver
      @servers.values.each { |server| add_method(server[:server], receiver) }     
    end

    def self.server(port)
      @servers ||= {}
      @servers[port] ||= { :server => OSC::EMServer.new(port) }
      @servers[port][:thread] ||= thread_for(port)
      @servers[port]
    end
    
    def self.thread_for(port)
      @servers[port][:thread] ||= Thread.new do
        @servers[port][:service] ||= Zeroconf::Service.new("Ruby", port).start
        Thread.abort_on_exception = true
        @servers[port][:server].run
      end
    end
    
    private
    
    def add_method(server, receiver)
      options = receiver[:options]
      obj = receiver[:target_obj]
      pattern = receiver[:pattern].dup
      # this prevents the same action being called multiple times when
      # an receiver object has multiple servers
      server.add_method(pattern) do |message| 
        unless @cached_message === message
          obj.send(:osc_on_receive, message, options, &receiver[:action]) 
          @cached_message = message
        end
      end
    end

  end

end
