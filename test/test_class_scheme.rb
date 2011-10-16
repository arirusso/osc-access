#!/usr/bin/env ruby

require 'helper'

class ClassSchemeTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_add_accessor
    scheme = ClassScheme.new
    options = { :pattern => "/1/fader1", :range => { :remote => 0..1, :local => 0..127 } }
    scheme.add_accessor(:whatever, options)
    assert_equal(1, scheme.accessors.size)
    accessor = scheme.accessors[:whatever]
    assert_equal(options, accessor[:options])
  end
  
  def test_add_writer
    scheme = ClassScheme.new
    options = { :pattern => "/1/fader1", :range => { :remote => 0..1, :local => 0..127 } }
    scheme.add_writer(:a_writer, options)
    assert_equal(1, scheme.writers.size)
    writer = scheme.writers[:a_writer]
    assert_equal(options, writer[:options])    
  end
  
  def test_add_reader
    scheme = ClassScheme.new
    options = { :pattern => "/1/fader1", :range => { :remote => 0..1, :local => 0..127 } }
    scheme.add_reader(:a_reader, options)
    assert_equal(1, scheme.readers.size)
    reader = scheme.readers[:a_reader]
    assert_equal(options, reader[:options])        
  end
  
  def test_ports
    scheme = ClassScheme.new
    scheme.ports = { :receive => 8001, :send => 9001 }
    ports = scheme.ports
    assert_equal(8001, ports.receive)
    assert_equal(9001, ports.transmit)       
  end
  
  def test_ports_receive_only
    scheme = ClassScheme.new
    scheme.ports = 8005
    ports = scheme.ports
    assert_equal(8005, ports.receive)
    assert_nil(ports.transmit)       
  end
  
  def test_send_ip
    scheme = ClassScheme.new
    assert_nil(scheme.remote_host)
    scheme.remote_host = "192.168.1.8"
    assert_equal("192.168.1.8", scheme.remote_host)      
  end
  
end