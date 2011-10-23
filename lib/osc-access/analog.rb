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
        to_range_length = @to_range.last - @to_range.first
        from_range_length = @from_range.last - @from_range.first
        factor = to_range_length.to_f / from_range_length.to_f
        computed_value = (input.to_f * factor.to_f) + @to_range.first # offset
        type = options[:type] || @type
        float_requested = !type.nil? && type.to_s.downcase == "float"
        float_requested ? computed_value : computed_value.to_i
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

end
