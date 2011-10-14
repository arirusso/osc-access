#!/usr/bin/env ruby
module OSCObject
  
  class ClassScheme

    attr_accessor :send_ip
    attr_reader :accessors, :readers, :server, :writers
    attr_writer :ports
    
    def initialize(options = {})
      @ports = { :receive => nil, :send => nil }
      port = @ports[:receive] || options[:port] || OSCObject::DefaultReceivePort
      @server = OSC::EMServer.new(port)
      @accessors, @readers, @writers = {}, {}, {}
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
    
    def add_reader(attr, options = {}, &block)
      @readers[attr] = { :options => options, :block => block }
    end
    
    def add_writer(attr, options = {}, &block)
      @writers[attr] = { :options => options, :block => block }
    end
    
  end

end
