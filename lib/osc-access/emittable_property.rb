#!/usr/bin/env ruby
module OSCAccess

  class EmittableProperty
    
    attr_reader :pattern, :subject
    
    def initialize(subject, pattern, options = {})
      @subject = subject
      @pattern = pattern
      @translate = options[:translate]
    end
    
    def value(target_obj)        
      raw_val = case @subject
        when Proc then @subject.call(target_obj)
        when Symbol then target_obj.send(@subject)
      end
      val = @translate.nil? ? raw_val : Translate.using(raw_val, @translate, :to_local => false)
      val = convert_booleans(val)
      [val].flatten     
    end
    
    private
    
    def convert_booleans(val)
      (val === true ? 1 : (val === false ? 0 : val))
    end
    
  end

end
