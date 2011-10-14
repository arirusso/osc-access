#!/usr/bin/env ruby
module OSCObject
  
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

    def self.process(value, range)
      new_vals = [value].flatten.map do |single_value|
        if range.kind_of?(Range)
          remote = 0..1
          local = range
        else
          remote = range[:remote] || (0..1)
          local = range[:local]
        end
        RangeAnalog.new(remote, local).process(value)
      end
      value.kind_of?(Array) ? new_vals : new_vals.first
    end

  end

end
