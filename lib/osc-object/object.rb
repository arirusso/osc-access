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
    osc_receive(pattern) { |this, msg| on_receive_osc(attr, msg, options, &block) }
  end

  def osc_receive(pattern, &block)
    @osc.receive(self, pattern, &block)
  end

  def self.included(base)
    base.extend(Class)
  end
  
  def osc_return(msg, options = {})
    val = options[:array] ? msg.args : msg.args.first
    @osc.transmit(OSC::Message.new(msg.address, val))
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

  def osc_on_receive(attr, msg, options = {}, &block)
    osc_set_local_value(attr, msg, options) unless options[:set_local] == false
    osc_return(msg, options) unless options[:get_local] == false
    yield(self, val) unless block.nil?
  end

  private
  
  def osc_set_local_value(attr, msg, options = {})
    arg = options[:arg] || 0
    array = (!arg.nil? && arg == :all)
    use_range = !options[:range].nil?
    
    val = array ? msg.args : msg.args[arg]
    val = RangeAnalog.process(val, options[:range]) if use_range
    p val
    instance_variable_set("@#{attr}", val)
  end
  
  def osc_add_hash_mapping(mapping)
    osc_range = mapping[:osc_range] || (0..1)
    @server.add_method(mapping[:pattern]) do | message |
      raw_value = message.to_a.first
      computed_value = compute_value(raw_value, osc_range, mapping[:range], :type => mapping[:type])
      self.send(mapping[:property], computed_value) if self.respond_to?(mapping[:property])
    end
  end

  def osc_load_hash_map(map)
    @map = map
    @map.each { |mapping| add_hash_mapping(mapping) }
  end

end
