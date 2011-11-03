#!/usr/bin/env ruby
module OSCAccess

  class EmittableProperty
    
    attr_reader :action, :arg, :pattern, :subject
    
    def initialize(subject, pattern, options = {})
      @subject = subject
      @pattern = pattern
      @arg = options[:arg]
      @translate = options[:translate]
      @action = options[:action]
    end
    
    def value(target_obj)
      val = case @subject
        when Proc then @subject.call(target_obj)
        when Symbol then target_obj.send(@subject)
      end
      [val].flatten   
    end
    
    def translated(target_obj)        
      raw_val = value(target_obj)
      @translate.nil? ? raw_val : Translate.using(raw_val, @translate, :to_local => false)  
    end
    
  end

end
