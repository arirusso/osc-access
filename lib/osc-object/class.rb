#!/usr/bin/env ruby
module OSCObject

  module Class

    attr_reader :osc_class_scheme

    def osc_accessor(*a)
      ensure_initialized
      @osc_class_scheme.add_accessor(*a, &block) 
    end
    
    def osc_writer(attr, options = {}, &block)
      ensure_initialized
      @osc_class_scheme.add_writer(*a, &block)       
    end
    
    def osc_reader(attr, options = {}, &block)
      ensure_initialized
      @osc_class_scheme.add_reader(*a, &block)       
    end
    
    def osc_send_ip(ip)
      @osc_class_scheme.send_ip = ip
    end
    
    def osc_port(val)
      @osc_class_scheme.ports = val
    end
    
    private
    
    def ensure_initialized
      @osc_class_scheme ||= ClassScheme.new
    end

  end

end
