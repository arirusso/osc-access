#!/usr/bin/env ruby
module OSCAccess
  
  class ClassScheme

    attr_reader :accessors, 
                :inputs, 
                :outputs, 
                :readers, 
                :writers
    
    def initialize
      @inputs, @outputs = [], []
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
