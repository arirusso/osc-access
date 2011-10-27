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

    def osc_send(*a)
      osc_initialize
      if a.first.kind_of?(OSC::Message)
        msg = a.pop
        osc_send(*a) unless a.empty?
      else
        msg = OSC::Message.new(*a)
      end
      @osc.transmit(msg)
    end

    def osc_join
      osc_initialize
      @osc.join
    end

    # osc_output takes arguments as such:
    #
    # osc_output(:host => "localhost", :port => 9000)
    # osc_output(:host => "localhost", :port => [9000, 9002, 9005])
    # osc_output(:host => "localhost", :port => 9000..9010)
    #    
    def osc_output(pair)
      osc_initialize
      ports = osc_process_ports_args(pair[:port])
      ports.each { |port| @osc.add_client(pair[:host], port) }
    end
    
    # osc_input takes arguments as such:
    #
    # osc_input(8000)
    # osc_input(:port => 8000)
    # osc_input(8000, 8005, 8010)
    # osc_input(8000..8010)
    #
    def osc_input(*args)
      osc_initialize
      ports = osc_process_ports_args(args)
      ports.each { |port| @osc.add_server(port) }
    end
    
    def osc_start(options = {})
      osc_initialize(options)
      osc_initialize_from_class_def
      osc_load_map(options[:map]) unless options[:map].nil?
      
      osc_input(options[:input_port]) unless options[:input_port].nil?
      osc_output(options[:output]) unless options[:output].nil?
      
      IO.start(:zeroconf_name => options[:service_name])
      @osc.threads.values.last || Thread.new { loop {} }
    end
    
    def osc_load_map(map)
      osc_initialize
      map.each { |attr, mapping| osc_add_map_row(attr, mapping) }      
    end
    
    def osc_translate(value, range)
      new_vals = [value].flatten.map do |single_value|
        if range.kind_of?(Range) || range.kind_of?(Array)
          remote = 0..1
          local = range
          type = nil
        else
          remote = range[:remote] || DefaultRemoteRange
          local = range[:local]
          type = range[:type]
        end
        Analog.new(remote, local).process(value, :type => type)
      end
      value.kind_of?(Array) ? new_vals : new_vals.first
    end

    protected

    def osc_on_receive(msg, options = {}, &block)
      val = osc_process_arg_option(msg, options)
      val = osc_translate(val, options[:translate]) unless options[:translate].nil?
      osc_send(msg) if options[:thru]
      yield(self, val, msg) unless block.nil?
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
      action = mapping.kind_of?(Hash) ? mapping[:action] : mapping
      osc_receive(pattern, mapping, &action)
    end
    
    def osc_process_arg_option(msg, options = {})
      arg = options[:arg] || 0
      array = (!arg.nil? && arg == :all)
      array ? msg.args : msg.args[arg]
    end
    
    def osc_process_ports_args(args)
      case args
        when Array then args.map { |a| osc_process_ports_args(a) }.flatten
        when Hash then osc_process_ports_args(args[:port])
        when Range then args.to_a
        when Numeric then [args]
      end
    end
    
  end

end
