#!/usr/bin/env ruby
module OSCAccess
  
  class RangeAnalog
    
    def initialize(from_range, to_range, options = {})
      @type = options[:type]

      @from_range = from_range
      @to_range = to_range
    end

    def process(input, options = {})
      to_range_length = @to_range.last - @to_range.first
      from_range_length = @from_range.last - @from_range.first
      factor = to_range_length.to_f / from_range_length.to_f
      computed_value = input.to_f * factor.to_f
      computed_value = computed_value + @to_range.first # offset
      type = options[:type] || @type
      float_requested = !type.nil? && type.to_s.downcase == "float"
      float_requested ? computed_value : computed_value.to_i
    end

  end

end
