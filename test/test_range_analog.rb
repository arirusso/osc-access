#!/usr/bin/env ruby

require 'helper'

class RangeAnalogTest < Test::Unit::TestCase

  include OSCObject
  include TestHelper
  
  def test_process_amplify
    ra = RangeAnalog.new(0..1, 0..127)
    output = ra.process(0.10)
    assert_equal(12, output)
  end
  
  def test_process_deamplify
    ra = RangeAnalog.new(0..150, 0..15)
    output = ra.process(22)
    assert_equal(2, output)    
  end
  
  def test_process_float
    ra = RangeAnalog.new(0..120, 0..1, :type => :float)
    output = ra.process(12)
    assert_equal(0.10, output)     
  end
  
end