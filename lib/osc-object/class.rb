#!/usr/bin/env ruby
module OSCObject

  module Class

    def osc_class_scheme
      osc_ensure_initialized
      @osc_class_scheme
    end

    def osc_accessor(*a, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_accessor(*a, &block) 
    end
    
    def osc_writer(attr, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_writer(*a, &block)       
    end
    
    def osc_reader(attr, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_reader(*a, &block)       
    end
    
    def osc_send_ip(ip)
      osc_ensure_initialized
      @osc_class_scheme.send_ip = ip
    end
    
    def osc_port(val)
      osc_ensure_initialized
      @osc_class_scheme.ports = val
    end
    
    private
    
    def osc_ensure_initialized
      @osc_class_scheme ||= ClassScheme.new
    end

  end

end
