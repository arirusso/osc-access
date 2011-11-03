#!/usr/bin/env ruby
module OSCAccess
  
  module Analog

    def self.new(from, to, options = {})
      case to
        when Array then Set.new(from, to, options)
        when ::Range then Range.new(from, to, options)
      end
    end
    
    class Range
      
      def initialize(from_range, to_range, options = {})
        @type = options[:type]

        @from_range = from_range
        @to_range = to_range
      end

      def process(input, options = {})
        to_range_len = (@to_range.last - @to_range.first).abs
        from_range_len = (@from_range.last - @from_range.first).abs
        abs_input = input - @from_range.first
        proportion = to_range_len.to_f / from_range_len.to_f
        abs_output = proportion.to_f * abs_input.to_f
        output = abs_output + @to_range.first

        type = options[:type] || @type
        float_requested = !type.nil? && type.to_s.downcase == "float"
        float_requested ? output : output.to_i
      end

    end

    class Set
      
      def initialize(from_range, to_set, options = {})
        @from_range = from_range
        @to_set = to_set
      end

      def process(input, options = {})
        from_range_length = @from_range.last - @from_range.first
        input_pct = input.to_f / from_range_length.to_f
        index = ((input_pct * @to_set.size).to_i - 1)
        @to_set.at(index)
      end

    end

  end
  
  class Translate
    
    def self.using(value, range, options = {})
      to_local = options[:to_local].nil? ? true : options[:to_local]
      new_vals = [value].flatten.compact.map do |single_val|
        if range == :boolean
          to_local ? (single_val <= 0 ? false : true) : (single_val ? 1 : 0)
        else
          if range.kind_of?(Range) || range.kind_of?(Array)
            remote = DefaultRemoteRange
            local = range
            type = options[:type]
          else
            remote = range[:remote] || DefaultRemoteRange
            local = range[:local]
            type = range[:type] || options[:type]
          end
          analog = to_local ? Analog.new(remote, local) : Analog.new(local, remote)
          type = to_local ? type : :float
          analog.process(single_val, :type => type)
        end
      end
      value.kind_of?(Array) ? new_vals : new_vals.first
    end

  end

end
