#!/usr/bin/env ruby
module OSCAccess
  
  class PortSpec
    
    attr_reader :receive, :transmit
    
    def initialize(spec)
      unless spec.nil? 
        case spec
          when Numeric then @receive = spec
          when Hash then
            @receive = spec[:receive]
            @transmit = spec[:send] || spec[:transmit]
        end
      end      
    end

  end

end
