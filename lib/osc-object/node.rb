#!/usr/bin/env ruby
module OSCObject

  module Node
    
    def self.included(base)
      base.extend(Class)
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
      should_override = self.respond_to?("#{attr.to_s}=") && options[:get_local] != false
      osc_override_attr_accessor(attr, pattern, options) if should_override
    end

    def osc_receive(pattern, &block)
      @osc.receive(self, pattern, &block)
    end

    def osc_send(msg)
      @osc.transmit(msg)
    end

    def osc_return(msg, options = {})
      val = osc_get_arg(msg, options)
      return_msg = OSC::Message.new(msg.address, val)
      osc_send(return_msg)
    end

    def osc_join
      @osc.thread.join
    end

    def osc_start(options = {})
      scheme = self.class.osc_class_scheme
      ports_from_options = PortSpec.new(options[:port])
      port_spec = ports_from_options || scheme.ports || DefaultPorts
      @osc = IO.new(self, port_spec, :remote_host => options[:remote_host])
      scheme.accessors.each { |attr, args| osc_accessor(attr, args[:options], &args[:block]) }
      #load_hash_map(map) unless map.nil?
      @osc.start
      osc_join if options[:join]
      @osc.thread
    end

    protected

    def osc_on_receive(attr, msg, options = {}, &block)
      osc_set_local_value(attr, msg, options) unless options[:set_local] == false
      osc_return(msg, options) unless options[:get_local] == false
      yield(self, val) unless block.nil?
    end

    private

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

    def osc_set_local_value(attr, msg, options = {})
      val = osc_get_arg(msg, options)
      use_range = !options[:range].nil?
      val = osc_analog(val, options[:range]) if use_range
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

end
