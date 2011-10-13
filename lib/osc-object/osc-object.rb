#!/usr/bin/env ruby
module OSCObject
  
  DefaultPattern = /.*/
  DefaultReceivePort = 8000
  
  def initialize(options = {})
    thread = start_receiving_osc(options)
    thread.join if options[:join]
  end
  
  def start_receiving_osc(options = {})
    port = self.class.osc_receive_port || options[:receive_port] || DefaultReceivePort
    map = options[:map]

    # pull osc server info from class instance vars
    @osc_server = self.class.osc_server || OSC::EMServer.new(port)
    @osc_client = OSC::Client.new( '192.168.1.9', 9000 )
    self.class.osc_patterns.each { |pattern, block| receive_osc(pattern.dup, &block) }
    
    load_hash_map(map) unless map.nil?
    
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
    
    def osc_accessor(attr, options = {}, &block)
      pattern = options[:pattern] || DefaultPattern
      receive_osc(pattern) do |this, msg|
        if options[:range].nil?
          val = msg.args.first 
        else
          if options[:range].kind_of?(Range)
            input = 0..1
            output = options[:range]
          else
            input = options[:range][:input] || (0..1)
            output = options[:range][:output]
          end
          val = map_range(msg.args.first, input, output)
        end
        unless options[:return].nil?
          client = this.instance_variable_get("@osc_client")
          return_value = case options[:return]
            when :value then val
            when Proc then options[:return].call(msg)
            else options[:return]
          end
          client.send(OSC::Message.new( msg.address , return_value ))
        end
        block.nil? ? this.instance_variable_set("@#{attr}", val) : yield(this, val)
      end
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
    
    private
    
    def map_range(value, input, output, &block)
      RangeAnalog.new(input, output).process(value)
    end

  end

  private
  
  def start_osc_server
    Thread.new do 
      Thread.abort_on_exception = true
      @osc_server.run
    end
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

end
