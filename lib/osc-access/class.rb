#!/usr/bin/env ruby
module OSCAccess

  module Class

    def osc_class_scheme
      osc_ensure_initialized
      @osc_class_scheme
    end
    
    def osc_receive(pattern, options = {}, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_receiver(pattern, options, &block)
    end
    
    def osc_output(args)
      osc_ensure_initialized
      @osc_class_scheme.outputs << args
    end
    
    def osc_input(val)
      osc_ensure_initialized
      @osc_class_scheme.inputs << val
    end
    
    private
    
    def osc_ensure_initialized
      @osc_class_scheme ||= ClassScheme.new
    end

  end

end
