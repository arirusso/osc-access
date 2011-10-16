#!/usr/bin/env ruby
module OSCObject

  module Class

    def osc_class_scheme
      osc_ensure_initialized
      @osc_class_scheme
    end

    def osc_accessor(attr, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_accessor(attr, options, &block) 
    end
    
    def osc_writer(attr, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_writer(attr, options, &block)       
    end
    
    def osc_reader(attr, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_reader(attr, options, &block)       
    end
    
    def osc_remote_host(host)
      osc_ensure_initialized
      @osc_class_scheme.remote_host = host
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
