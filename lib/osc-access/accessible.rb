#!/usr/bin/env ruby
module OSCAccess

  module Accessible
    
    def self.included(base)
      base.extend(Class)
    end

    def osc_receive(pattern, options = {}, &block)
      osc_initialize
      @osc_receiver.add_receiver(self, pattern, options, &block)
      if !options[:accessor].nil?
        @osc_properties << EmittableProperty.new(options[:accessor], pattern, options)
      elsif !options[:initialize].nil?
        @osc_properties << EmittableProperty.new(options[:initialize], pattern, options)
      end
    end
        
    def osc_send_property(prop)
      prop = @osc_properties.find { |ep| ep.subject == prop } if prop.kind_of?(Symbol)
      val = prop.translated(self)
      msg = OSC::Message.new(prop.pattern, *val)
      @osc_emitter.transmit(msg)
      local_msg = OSC::Message.new(prop.pattern, *prop.value(self))
      local_val = osc_process_arg_option(local_msg, :arg => prop.arg)
      prop.action.call(self, local_val, local_msg) unless prop.action.nil?
    end
    
    def osc_send(*a)
      osc_initialize
      a.first.kind_of?(Symbol) ? osc_send_property(a.first) : @osc_emitter.transmit(*a)      
    end

    def osc_join(options = {})
      osc_initialize
      @osc_receiver.join(options)
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
      ports.each { |port| @osc_emitter.add_client(pair[:host], port) }
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
      ports.each { |port| @osc_receiver.add_server(port) }
    end
    
    def osc_start(options = {})
      osc_initialize(options)
      osc_initialize_from_class_def
      osc_load_map(options[:map]) unless options[:map].nil?
      
      osc_input(options[:input_port]) unless options[:input_port].nil?
      osc_output(options[:output]) unless options[:output].nil?
      
      Thread.new do 
        sleep(1) 
        osc_send_all_properties
      end
      
      @osc_receiver.threads.last || Thread.new { loop {} }
    end
    
    def osc_send_all_properties
      osc_initialize
      @osc_properties.each { |prop| osc_send_property(prop) }
    end
    
    def osc_load_map(map)
      osc_initialize
      map.each { |attr, mapping| osc_add_map_row(attr, mapping) }      
    end
    
    def osc_translate(value, range, options = {})
      Translate.using(value, range, options)
    end

    protected

    def osc_on_receive(msg, options = {}, &block)
      val = osc_process_arg_option(msg, options)
      val = osc_translate(val, options[:translate]) unless options[:translate].nil?
      osc_send(msg) if options[:thru]
      accessor = options[:accessor]
      self.send("#{accessor.to_s}=", val) unless accessor.nil?
      yield(self, val, msg) unless block.nil?
    end

    private

    def osc_initialize(options = {})
      @osc_emitter ||= Emitter.new
      @osc_properties ||= []
      @osc_receiver ||= Receiver.new
    end
        
    def osc_initialize_from_class_def
      scheme = self.class.osc_class_scheme
      scheme.inputs.each { |port| @osc_receiver.add_server(port) }
      scheme.outputs.each { |hash| @osc_emitter.add_client(hash) }
      scheme.receivers.each { |hash| osc_receive(hash[:pattern], hash[:options], &hash[:action]) }  
    end
    
    def osc_add_map_row(pattern, mapping)
      options = mapping.kind_of?(Hash) ? mapping : {}
      action = mapping.kind_of?(Hash) ? mapping[:action] : mapping
      osc_receive(pattern, options, &action)
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
