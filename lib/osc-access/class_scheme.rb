#!/usr/bin/env ruby
module OSCAccess
  
  class ClassScheme

    attr_accessor :remote_host
    attr_reader :accessors, :readers, :writers
    attr_writer :ports
    
    def initialize
      @ports = { :receive => nil, :transmit => nil }
      @accessors, @readers, @writers = {}, {}, {}
    end
    
    def ports
      PortSpec.new(@ports)
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
