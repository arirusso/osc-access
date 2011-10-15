#!/usr/bin/env ruby
module OSCObject
  
  class IO
    
    extend Forwardable
    
    attr_reader :thread
    def_delegators :thread, :join, :exit
    
    def initialize(target_obj, scheme, options = {})

      ports = scheme.ports
      port = ports[:receive] || options[:receive_port] || DefaultReceivePort
      map = options[:map]

      # pull osc server info from class instance vars
      @server = scheme.server || OSC::EMServer.new(port)

      send_ip = options[:send_ip] || scheme.send_ip

      unless send_ip.nil?
        remote_port = ports[:send] || options[:send_port] || DefaultSendPort
        @client = OSC::Client.new( options[:send_ip], remote_port )
      end
      
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

  end

end
