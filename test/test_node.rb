#!/usr/bin/env ruby

require 'helper'

class NodeTest < Test::Unit::TestCase

  include OSCObject
  include TestHelper
  
  def test_osc_analog
    outp = $stub_object.send(:osc_analog, 0.8, :local => 0..127, :remote => 0..1)
    assert_equal(101, outp)      
  end
  
  def test_osc_analog_default_remote
    outp = $stub_object.send(:osc_analog, 0.5, 0..127)
    assert_equal(63, outp)      
  end
  
  def test_osc_analog_float
    outp = $stub_object.send(:osc_analog, 12, :remote => 0..120, :local => 0..1, :type => :float)
    assert_equal(0.10, outp)     
  end
  
end