#!/usr/bin/env ruby
module OSCObject
      
    def receive_osc(pattern, &block)
      @osc_server.add_method(self, pattern, &block)
    end
    
    private
    
    def compute_value(raw_value, old_range, new_range, options = {})
      new_range_length = new_range.last - new_range.first
      old_range_length = old_range.last - old_range.first
      factor = new_range_length.to_f / old_range_length.to_f
      computed_value = raw_value.to_f * factor.to_f
      computed_value = computed_value + new_range.first # offset
      float_requested = !options[:type].nil? && options[:type].to_s.downcase == "float"
      float_requested ? computed_value : computed_value.to_i
    end
    
    def add_mapping(instrument, mapping)
      osc_range = mapping[:osc_range] || (0..1)
      @server.add_method(mapping[:pattern]) do | message |
        raw_value = message.to_a.first
        computed_value = compute_value(raw_value, osc_range, mapping[:range], :type => mapping[:type])
        instrument.send(mapping[:property], computed_value) if instrument.respond_to?(mapping[:property])
        #p "set #{mapping[:property]} to #{computed_value}"
      end
    end
    
    def load_rx_map(instrument, map)
      @map = map
      @map.each { |mapping| add_mapping(instrument, mapping) }
    end
    
    def initialize_receive_osc(options = {})
      port = options[:port] || 8000
      map = options[:map] 
      
      @osc_server = OSCServer.new(self, port)
      load_rx_map(self, map)
      @osc_server.start(:background => true) unless !options[:start_osc].nil? && options[:start_osc] == false 
    end
  
end
