#!/usr/bin/env ruby
module OSCObject
  
  def initialize(options = {})
    osc_start(options)
  end
  
  def osc_reader(attr, options = {}, &block)
    options[:get_local] = false
    osc_accessor(attr, options, &block)
  end
  
  def osc_writer(attr, options = {}, &block)
    options[:set_local] = false
    osc_accessor(attr, options, &block)
  end
    
  def osc_accessor(attr, options = {}, &block)
    pattern = options[:pattern] || DefaultPattern
    receive_osc(pattern) { |this, msg| on_receive_osc(attr, msg, options, &block) }
  end

  def receive_osc(pattern, &block)
    @osc.receive(self, pattern, &block)
  end

  def self.included(base)
    base.extend(Class)
  end

  protected

  def osc_start(options = {})
    scheme = self.class.osc_class_scheme
    @osc = IO.new(self, scheme, options)
    scheme.accessors.each { |attr, args| osc_accessor(attr, args[:options], &args[:block]) }
    #load_hash_map(map) unless map.nil?
    thread = @osc.start
    thread.join if options[:join]
    thread
  end

  def on_receive_osc(attr, msg, options = {}, &block)
    set_local_value_from_osc(attr, msg, options) unless options[:set_local] == false
    return_osc(msg, options) unless options[:get_local] == false
    yield(self, val) unless block.nil?
  end

  private
  
  def set_local_value_from_osc(attr, msg, options = {})
    arg = options[:arg] || 0
    array = (!arg.nil? && arg == :all)
    use_range = !options[:range].nil?
    
    val = array ? msg.args : msg.args[arg]
    val = RangeAnalog.process(val, options[:range]) if use_range
    p val
    instance_variable_set("@#{attr}", val)
  end
  
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
