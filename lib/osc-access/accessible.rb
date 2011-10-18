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
      [args].flatten.each do { |pair| @osc.add_client(pair[:host], pair[:port]) }
    end
    
    def osc_input(arg)
      osc_initialize
      just_ports = arg.kind_of?(Hash) ? arg[:port] : arg
      [just_ports].flatten.each { |port| @osc.add_server(port) }
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

    def osc_on_receive(msg, options = {}, &block)
      val = osc_get_arg(msg, options)
      val = osc_translate(val, options[:translate]) unless options[:translate].nil?
      yield(self, val)
    end

    private

    def osc_initialize(options = {})
      @osc ||= IO.new(options)
    end
        
    def osc_initialize_from_class_def
      scheme = self.class.osc_class_scheme
      scheme.inputs.each { |port| @osc.add_server(port) }
      scheme.outputs.each { |hash| @osc.add_client(hash) }
      scheme.receivers.each { |hash| osc_receive(hash[:pattern], hash[:options], &hash[:action]) }  
    end
    
    def osc_add_map_row(pattern, mapping)
      osc_receive(pattern, mapping, &mapping[:action])
    end
    
    def osc_get_arg(msg, options = {})
      arg = options[:arg] || 0
      array = (!arg.nil? && arg == :all)
      array ? msg.args : msg.args[arg]
    end
    
  end

end
