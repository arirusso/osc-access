#!/usr/bin/env ruby
module OSCObject

  module OSCObjectClass

    attr_reader :osc_action_scheme

    def osc_accessor(*a)
      ensure_initialized
      @osc_action_scheme.add_accessor(*a, &block) 
    end
    
    def osc_writer(attr, options = {}, &block)
      
    end
    
    def osc_send_ip(ip)
      @osc_action_scheme.send_ip = ip
    end
    
    def osc_port(val)
      @osc_action_scheme.ports = val
    end
    
    private
    
    def ensure_initialized
      @osc_action_scheme ||= OSCActionScheme.new
    end

  end

end
