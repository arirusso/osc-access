#!/usr/bin/env ruby
module OSCObject

  module OSCObjectClass

    attr_reader :osc_action_scheme

    def osc_accessor(*a, &block)
      ensure_initialized
      @osc_action_scheme.add_accessor(*a, &block) 
    end
    
    def osc_writer(attr, options = {}, &block)
      
    end
    
    # ensure that @osc_action_scheme is initialized and delegate to it
    def method_missing(method, *args, &block)
      ensure_initialized
      @osc_action_scheme.respond_to?(method) ? @osc_action_scheme.send(method, *args, &block) : super
    end
    
    private
    
    def ensure_initialized
      @osc_action_scheme ||= OSCActionScheme.new
    end

  end

end
