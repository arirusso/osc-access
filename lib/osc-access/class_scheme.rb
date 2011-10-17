#!/usr/bin/env ruby
module OSCAccess
  
  class ClassScheme

    attr_reader :inputs, 
                :outputs, 
                :receivers
    
    def initialize
      @inputs, @outputs, @receivers = [], [], []
    end
    
    def add_receiver(pattern, options = {}, &block)
      @receivers << { :pattern => pattern, :options => options, :action => block }
    end
    
  end

end
