#!/usr/bin/env ruby
module OSCAccess

  module Accessible
    
    def self.included(base)
      base.extend(Class)
    end

    def osc_receive(pattern, options = {}, &block)
      osc_initialize
      @osc.receive(self, pattern, options, &block)
    end

    def osc_send(msg)
      osc_initialize
      @osc.transmit(msg)
    end
    
    def osc_send_val(pattern, val)
      msg = OSC::Message.new(pattern, val)
      osc_send(msg)
    end

    def osc_join
      osc_initialize
      @osc.join
    end
    
    def osc_output(args)
      osc_initialize
      @osc.add_client(args[:host], args[:port])
    end
    
    def osc_input(arg)
      osc_initialize
      port = arg.kind_of?(Hash) ? arg[:port] : arg
      @osc.add_server(port)
    end
    
    def osc_start(options = {})
      osc_initialize(options)
      @osc.initialize_node(options)
      osc_initialize_from_class_def
      osc_load_map(options[:map]) unless options[:map].nil?
      @osc.threads.values.last || Thread.new { loop {} }
    end
    
    def osc_load_map(map)
      osc_initialize
      map.each { |attr, mapping| osc_add_map_row(attr, mapping) }      
    end
    
    def osc_translate(value, range)
      new_vals = [value].flatten.map do |single_value|
        if range.kind_of?(Range)
          remote = 0..1
          local = range
          type = nil
        else
          remote = range[:remote] || DefaultRemoteRange
          local = range[:local]
          type = range[:type]
        end
        RangeAnalog.new(remote, local).process(value, :type => type)
      end
      value.kind_of?(Array) ? new_vals : new_vals.first
    end

    protected

    def osc_on_receive(attr, msg, options = {}, &block)
      is_get = msg.to_a.empty?
      osc_set_local(attr, msg, options) unless options[:set_local] == false || is_get
      osc_get_local(attr, msg.address)  unless options[:get_local] == false
      yield(self, val) unless block.nil?
    end

    private

    def osc_initialize(options = {})
      @osc ||= IO.new(options)
    end
    
    def osc_reader(attr, options = {}, &block)
      options[:set_local] = false
      osc_accessor(attr, options, &block)
    end

    def osc_writer(attr, options = {}, &block)
      options[:get_local] = false
      osc_accessor(attr, options, &block)
    end

    def osc_accessor(attr, options = {}, &block)
      osc_initialize
      pattern = options[:pattern] || DefaultPattern
      osc_receive(pattern) { |this, msg| osc_on_receive(attr, msg, options, &block) }
    end
        
    def osc_initialize_from_class_def
      scheme = self.class.osc_class_scheme
      scheme.inputs.each { |port| @osc.add_server(port) }
      scheme.outputs.each { |hash| @osc.add_client(hash) }
      scheme.receivers.each { |hash| osc_receive(hash[:pattern], options, &hash[:proc]) }
      #scheme.accessors.each { |attr, args| osc_accessor(attr, args[:options], &args[:block]) }
      #scheme.readers.each { |attr, args| osc_reader(attr, args[:options], &args[:block]) }
      #scheme.writers.each { |attr, args| osc_writer(attr, args[:options], &args[:block]) }      
    end
    
    def osc_get_local(attr, pattern)
      val = instance_variable_get("@#{attr.to_s}")
      osc_send_val(pattern, val)
    end

    def osc_set_local(attr, msg, options = {})
      val = osc_get_arg(msg, options)
      use_range = !options[:range].nil?
      val = osc_analog(val, options[:range]) if use_range
      respond_to?("#{attr}=") ? send("#{attr}=", val) : instance_variable_set("@#{attr}", val)
    end

    def osc_add_map_row(key, mapping)
      case key
        when String then osc_add_receiver_from_map(key, mapping)
        when Symbol then osc_add_accessor_from_map(key, mapping)
      end
    end
    
    def osc_add_receiver_from_map(pattern, mapping)
      osc_receive(pattern, mapping, &mapping[:proc])
    end

    def osc_add_accessor_from_map(attr, mapping)
      type = mapping[:type] || :accessor
      method = "osc_#{type}"
      self.send(method, key, mapping)
    end
    
  end

end
