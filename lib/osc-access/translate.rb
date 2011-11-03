#!/usr/bin/env ruby
module OSCAccess

  module Analog
    
    def self.new(from, to, options = {})
      case to
        when Array then Output::Set.new(Input.new(from), to, options)
        when ::Range then Output::Range.new(Input.new(from), to, options)
      end
    end
    
    module Input
      
      def self.new(input)
        case input
          when Array then Input::Set.new(input)
          when ::Range then Input::Range.new(input)
        end
      end
      
      class Range
        
        def initialize(range)
          @range = range
        end
        
        def numerator(input)
          (input - @range.first).to_f
        end
        
        def denominator
          (@range.last - @range.first).abs.to_f
        end
        
      end
      
      class Set

        def initialize(set)
          @set = set
        end
        
        def numerator(input)
          @set.index(input).to_f
        end
        
        def denominator
          (@set.size - 1).to_f
        end
                
      end
      
    end

    module Output
      
      class Range
        
        def initialize(from, to_range, options = {})
          @type = options[:type]

          @from = from
          @to_range = to_range
        end

        def process(input, options = {})
          to_range_len = (@to_range.last - @to_range.first).abs
          
          proportion = to_range_len.to_f / @from.denominator
          abs_output = proportion.to_f * @from.numerator(input)
          output = abs_output + @to_range.first

          type = options[:type] || @type
          float_requested = !type.nil? && type.to_s.downcase == "float"
          float_requested ? output : output.to_i
        end

      end

      class Set
        
        def initialize(from, to_set, options = {})
          @from = from
          @to_set = to_set
        end

        def process(input, options = {})
          proportion = @from.numerator(input) / @from.denominator
          index = [((proportion * @to_set.size).to_i - 1), 0].max
          @to_set.at(index)
        end

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
