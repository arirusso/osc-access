#!/usr/bin/env ruby
module OSCObject
  
  class OSCActionScheme

    attr_reader :accessors, :send_ip, :server
    
    def initialize(options = {})
      @ports = { :receive => nil, :send => nil }
      port = @ports[:receive] || options[:port] || OSCObject::DefaultReceivePort
      @server = OSC::EMServer.new(port)
      @accessors = {}
    end
    
    def ports
      ports = { :receive => nil, :send => nil }
      unless @ports.nil?
        case @ports
        when Numeric then ports[:receive] = port
        when Hash then
          ports[:receive] = @ports[:receive]
          ports[:send] = @ports[:send]
        end
      end
      ports
    end
    
    def add_accessor(attr, options = {}, &block)
      @accessors[attr] = { :options => options, :block => block }
    end

    def osc_send_ip(ip)
      @send_ip = ip
    end

    def osc_port(port)
      @ports = port
    end
    
  end

end
