#!/usr/bin/env ruby

require 'helper'

class AccessibleTest < Test::Unit::TestCase

  include OSCAccess
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
  
  def test_osc_output
    
  end
  
  def test_osc_input
    
  end
  
  #def test_change_receive_port
  #  
  #end
  
  #def test_change_transmit_port
  #  
  #end

  #def test_change_transmit_ip
  #  
  #end
    
  def test_class_included
    
  end

  def test_osc_accessor
    
  end
  
  def test_osc_reader
    
  end
  
  def test_osc_writer
    
  end

  def test_osc_receive
    
  end
  
  def test_osc_send
    
  end
  
  def test_osc_send_attr
    
  end

  def test_osc_start
    
  end

  def test_override_attr_accessor
    
  end
  
  def test_get_arg
    
  end

  def test_set_local_value
    
  end
  
end