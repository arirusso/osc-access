#!/usr/bin/env ruby
module OSCAccess

  module Accessible
    
    def self.included(base)
      base.extend(Class)
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
      should_override = self.respond_to?("#{attr.to_s}=") && options[:get_local] != false
      osc_override_attr_accessor(attr, pattern, options) if should_override
    end

    def osc_receive(pattern, &block)
      osc_initialize
      @osc.receive(self, pattern, &block)
    end

    def osc_send(msg)
      osc_initialize
      @osc.transmit(msg)
    end

    def osc_join
      osc_initialize
      @osc.join
    end
    
    def osc_output(args)
      osc_initialize
      port = args[:port] || DefaultOutputPort
      @osc.add_client(args[:host], port)
    end
    
    def osc_input(arg)
      osc_initialize
      port = arg.kind_of?(Hash) ? arg[:port] : arg
      @osc.add_server(port)
    end
    
    def osc_initialize(options = {})
      @osc ||= IO.new(options)
    end

    def osc_start(options = {})
      osc_initialize(options)
      osc_initialize_from_class_def
      osc_load_map(options[:map]) unless options[:map].nil?
      #@osc.start
      #osc_join #if options[:join]
      @osc.threads.values.last
    end
    
    def osc_load_map(map)
      osc_initialize
      map.each { |attr, mapping| add_map_row(attr, mapping) }      
    end

    protected

    def osc_on_receive(attr, msg, options = {}, &block)
      is_get = msg.to_a.empty?
      osc_set_local(attr, msg, options) unless options[:set_local] == false || is_get
      osc_get_local(attr, msg.address)  unless options[:get_local] == false
      yield(self, val) unless block.nil?
    end

    private
    
    def osc_initialize_from_class_def
      scheme = self.class.osc_class_scheme
      scheme.inputs.each { |port| @osc.add_server(port) }
      scheme.outputs.each { |hash| @osc.add_client(hash) }
      scheme.accessors.each { |attr, args| osc_accessor(attr, args[:options], &args[:block]) }
      scheme.readers.each { |attr, args| osc_reader(attr, args[:options], &args[:block]) }
      scheme.writers.each { |attr, args| osc_writer(attr, args[:options], &args[:block]) }      
    end
    
    def osc_get_local(attr, pattern)
      if respond_to?(attr)
        send(attr)
      else
        val = osc_sendinstance_variable_get("@#{attr}")
        msg = OSC::Message.new(pattern, val)
        osc_send(msg)
      end
    end

    def osc_override_attr_accessor(attr, pattern, options = {})
      self.class.send(:define_method, "#{attr}=") do |val|
        msg = OSC::Message.new(pattern, val)
        osc_send(msg)
        super
      end
    end

    def osc_get_arg(msg, options = {})
      arg = options[:arg] || 0
      array = (!arg.nil? && arg == :all)
      array ? msg.args : msg.args[arg]
    end
    
    def osc_analog(value, range)
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

    def osc_set_local(attr, msg, options = {})
      val = osc_get_arg(msg, options)
      use_range = !options[:range].nil?
      val = osc_analog(val, options[:range]) if use_range
      p val
      respond_to?("#{attr}=") ? send("#{attr}=", val) : instance_variable_set("@#{attr}", val)
    end

    def osc_add_map_row(attr, mapping)
      type = mapping[:type] || :accessor
      method = "osc_#{type}"
      self.send(method, attr, mapping)
    end

  end

end
