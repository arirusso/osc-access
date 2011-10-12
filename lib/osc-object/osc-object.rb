#!/usr/bin/env ruby
module OSCObject
  
  DefaultReceivePort = 8000
  
  def start_receiving_osc(options = {})
    port = self.class.osc_receive_port || options[:receive_port] || DefaultReceivePort
    p port
    map = options[:map]

    # pull osc server info from class instance vars
    @osc_server = self.class.osc_server || OSC::EMServer.new(port)
    self.class.osc_patterns.each { |pattern, block| receive_osc(pattern.dup, &block) }
    
    #load_rx_map(self, map)
    
    start_osc_server   
  end

  def receive_osc(pattern, &block)
    @osc_server.add_method(pattern) { |message| yield(self, message) }
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    attr_reader :osc_patterns, :osc_server
    
    def analog(value, options = {}, &block)
      new_val = RangeAnalog.new(options[:from], options[:to]).process(value)
      yield(new_val)
    end
    
    def receive_osc(pattern, options = {}, &block)
      port = @osc_receive_port || options[:port] || OSCObject::DefaultReceivePort
      @osc_server ||= OSC::EMServer.new(port)
      @osc_patterns ||= {}
      @osc_patterns[pattern] = block
    end
        
    def osc_receive_port(*a)
      if a.first.kind_of?(Numeric)
        @osc_receive_port = a.first
      end
      @osc_receive_port
    end

  end

  private
  
  def start_osc_server
    Thread.new { @osc_server.run }
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

end
