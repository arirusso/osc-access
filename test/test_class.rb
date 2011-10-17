#!/usr/bin/env ruby

require 'helper'

class ClassTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_osc_class_scheme
    obj = StubObject.new
    assert_not_nil(obj.class.osc_class_scheme)
  end
  
  def test_output_default_port
    obj = StubObject.new
    ip = "192.143.100.1"
    obj.class.osc_output(:host => ip)
    assert_equal(ip, obj.class.osc_class_scheme.outputs.last[:host])
  end
  
  def test_osc_input_and_output
    obj = StubObject.new
    obj.class.osc_input(8011)
    obj.class.osc_output(:host => "1.1.1.1", :port => 9012)
    assert_equal(8011, obj.class.osc_class_scheme.inputs.last)   
    assert_equal(9012, obj.class.osc_class_scheme.outputs.last[:port])   
  end
  
  def test_osc_input
    obj = StubObject.new
    obj.class.osc_input(8013)
    assert_equal(8013, obj.class.osc_class_scheme.inputs.first) 
    assert_nil(obj.class.osc_class_scheme.outputs.first)      
  end

  def test_osc_input_hash
    obj = StubObject.new
    obj.class.osc_input(:port => 8014)
    assert_equal({ :port => 8014 }, obj.class.osc_class_scheme.inputs.last)     
  end
  
end