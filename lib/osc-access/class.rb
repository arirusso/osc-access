#!/usr/bin/env ruby
module OSCAccess

  module Class

    def osc_class_scheme
      osc_ensure_initialized
      @osc_class_scheme
    end
    
    def osc_receive(pattern, &block)
      osc_ensure_initialized
      @osc_class_scheme.add_receiver(pattern, &block)
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
