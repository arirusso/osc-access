#!/usr/bin/env ruby
module OSCAccess
  
  class ClassScheme

    attr_reader :accessors, 
                :input_ports, 
                :outputs, 
                :readers, 
                :writers
    
    def initialize
      @input_ports, @outputs = [], []
      @accessors, @readers, @writers = {}, {}, {}
    end
    
    def add_accessor(attr, options = {}, &block)
      @accessors[attr] = { :options => options, :block => block }
    end
    
    def add_reader(attr, options = {}, &block)
      @readers[attr] = { :options => options, :block => block }
    end
    
    def add_writer(attr, options = {}, &block)
      @writers[attr] = { :options => options, :block => block }
    end
    
  end

end
