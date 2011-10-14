#!/usr/bin/env ruby
module OSCObject
  
  def initialize(options = {})
    start_receiving_osc(options)
  end
  
  def osc_accessor(attr, options = {}, &block)
    pattern = options[:pattern] || DefaultPattern
    receive_osc(pattern) { |this, msg| on_receive_osc(attr, msg, options, &block) }
  end

  def receive_osc(pattern, &block)
    @osc.receive(self, pattern, &block)
  end

  def self.included(base)
    base.extend(OSCObjectClass)
  end

  protected

  def start_receiving_osc(options = {})
    scheme = self.class.osc_action_scheme
    @osc = OSCIO.new(self, scheme, options)
    scheme.accessors.each { |attr, args| osc_accessor(attr, args[:options], &args[:block]) }
    #load_hash_map(map) unless map.nil?
    thread = @osc.start
    thread.join if options[:join]
    thread
  end

  def on_receive_osc(attr, msg, options = {}, &block)
    val = if options[:range].nil?
      options[:array] ? msg.args : msg.args.first
    else
      RangeAnalog.process(msg.args.first, options[:range])
    end
    p val
    return_osc(msg, options) unless options[:return] == false
    block.nil? ? instance_variable_set("@#{attr}", val) : yield(self, val)
  end

  private

  def add_hash_mapping(mapping)
    osc_range = mapping[:osc_range] || (0..1)
    @server.add_method(mapping[:pattern]) do | message |
      raw_value = message.to_a.first
      computed_value = compute_value(raw_value, osc_range, mapping[:range], :type => mapping[:type])
      self.send(mapping[:property], computed_value) if self.respond_to?(mapping[:property])
    end
  end

  def load_hash_map(map)
    @map = map
    @map.each { |mapping| add_hash_mapping(mapping) }
  end

  def return_osc(msg, options = {})
    val = options[:array] ? msg.args : msg.args.first
    @osc.transmit(OSC::Message.new(msg.address, val))
  end
  
end
