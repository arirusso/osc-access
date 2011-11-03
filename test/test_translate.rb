#!/usr/bin/env ruby

require 'helper'

class TranslateTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_range_process_amplify
    ra = Analog::Range.new(0..1, 0..127)
    output = ra.process(0.10)
    assert_equal(12, output)
  end
  
  def test_range_process_deamplify
    ra = Analog::Range.new(0..150, 0..15)
    output = ra.process(22)
    assert_equal(2, output)    
  end
  
  def test_negative_range
    
  end
  
  #def test_from_set_to_range
  #  ra = Analog::Range.new([0, 2, 4, 8, 16, 64], 0..10)
  #  output = ra.process(8)
  #  assert_equal(6, output)    
  #end
  
  def test_range_process_float
    ra = Analog::Range.new(0..120, 0..1, :type => :float)
    output = ra.process(12)
    assert_equal(0.10, output)     
  end
  
  def test_set_ascending
    sa = Analog::Set.new(0..1, [0, 2, 4, 8, 12, 16, 32, 64, 128, 512])
    output = sa.process(0.40)
    assert_equal(8, output)
  end
  
  def test_set_descending
    sa = Analog::Set.new(0..1, [512, 128, 64, 32, 16, 12, 8, 4, 2, 0])
    output = sa.process(0.40)
    assert_equal(32, output)
  end
  
  def test_range_class
    a = Analog.new(0..1, 0..100)
    assert_equal(Analog::Range, a.class)
  end
  
  def test_set_class
    a = Analog.new(0..1, [0, 10, 20, 50])
    assert_equal(Analog::Set, a.class)
  end
  
end