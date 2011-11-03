#!/usr/bin/env ruby

require 'helper'

class TranslateTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_range_process_amplify
    ra = Analog.new(0..1, 0..127)
    output = ra.process(0.10)
    assert_equal(12, output)
  end
  
  def test_range_process_deamplify
    ra = Analog.new(0..150, 0..15)
    output = ra.process(22)
    assert_equal(2, output)    
  end
  
  def test_neg_posi_to_posi
    ra = Analog.new(-24..24, 0..3, :type => :float)
    output = ra.process(10)
    assert_equal(2.125, output)      
  end
  
  def test_neg_posi_to_neg_posi
    ra = Analog.new(-24..24, -3..3, :type => :float)
    output = ra.process(10)
    assert_equal(1.25, output)      
  end
  
  def test_neg_to_neg_posi
    ra = Analog.new(-24..-12, -3..3, :type => :float)
    output = ra.process(-14)
    assert_equal(2, output)      
  end
  
  def test_neg_to_neg
    ra = Analog.new(-24..-12, -5..-3, :type => :float)
    output = ra.process(-16)
    assert_equal(-3.666666666666667, output)      
  end
  
  def test_neg_to_posi
    ra = Analog.new(-24..-12, 1..3, :type => :float)
    output = ra.process(-18)
    assert_equal(2, output)      
  end
  
  def test_from_set_to_range
    ra = Analog.new([0, 2, 4, 8, 16, 64], 0..10)
    output = ra.process(8)
    assert_equal(6, output)    
  end
  
  def test_range_process_float
    ra = Analog.new(0..120, 0..1, :type => :float)
    output = ra.process(12)
    assert_equal(0.10, output)     
  end
  
  def test_set_ascending
    sa = Analog.new(0..1, [0, 2, 4, 8, 12, 16, 32, 64, 128, 512])
    output = sa.process(0.40)
    assert_equal(8, output)
  end
  
  def test_set_descending
    sa = Analog.new(0..1, [512, 128, 64, 32, 16, 12, 8, 4, 2, 0])
    output = sa.process(0.40)
    assert_equal(32, output)
  end
  
  def test_range_class
    a = Analog.new(0..1, 0..100)
    assert_equal(Analog::Output::Range, a.class)
  end
  
  def test_set_class
    a = Analog.new(0..1, [0, 10, 20, 50])
    assert_equal(Analog::Output::Set, a.class)
  end
  
end