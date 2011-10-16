#!/usr/bin/env ruby

require 'helper'

class ClassTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_osc_class_scheme
    obj = $stub_object
    assert_not_nil(obj.class.osc_class_scheme)
  end
  
  def test_osc_accessor(*a, &block)
    obj = $stub_object
    options = { :pattern => /.*/ }
    obj.class.osc_accessor(:whatever, options)
    assert_equal(1, obj.class.osc_class_scheme.accessors.size)
    assert_equal(options, obj.class.osc_class_scheme.accessors[:whatever][:options])
  end
    
  def test_osc_writer(*a, &block)
    obj = $stub_object
    options = { :pattern => /.*/ }
    obj.class.osc_writer(:whatever, options)
    assert_equal(1, obj.class.osc_class_scheme.writers.size)
    assert_equal(options, obj.class.osc_class_scheme.writers[:whatever][:options])
  end
  
  def test_osc_reader(*a, &block)
    obj = $stub_object
    options = { :pattern => /.*/ }
    obj.class.osc_reader(:whatever, options)
    assert_equal(1, obj.class.osc_class_scheme.readers.size)
    assert_equal(options, obj.class.osc_class_scheme.readers[:whatever][:options])
  end
  
  def test_send_ip
    obj = $stub_object
    ip = "192.143.100.1"
    obj.class.osc_remote_host(ip)
    assert_equal(ip, obj.class.osc_class_scheme.remote_host)
  end
  
  def test_osc_port
    obj = $stub_object
    ports = { :receive => 8002, :send => 9002 }
    obj.class.osc_port(ports)
    assert_equal(8002, obj.class.osc_class_scheme.ports.receive)   
    assert_equal(9002, obj.class.osc_class_scheme.ports.transmit)   
  end
  
  def test_osc_port_receive_only
    obj = $stub_object
    port = 8003
    obj.class.osc_port(port)
    assert_equal(port, obj.class.osc_class_scheme.ports.receive) 
    assert_nil(obj.class.osc_class_scheme.ports.transmit)      
  end

end