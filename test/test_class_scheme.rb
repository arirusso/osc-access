#!/usr/bin/env ruby

require 'helper'

class ClassSchemeTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_ports
    scheme = ClassScheme.new
    scheme.outputs << { :host => "1.1.1.1", :port => 8001 }
    scheme.inputs << 9001
    assert_equal(8001, scheme.outputs.first[:port])
    assert_equal(9001, scheme.inputs.first)       
  end
  
  def test_ports_receive_only
    scheme = ClassScheme.new
    scheme.inputs << 8005
    assert_equal(8005, scheme.inputs.first)
    assert_nil(scheme.outputs.first)       
  end
  
  def test_send_ip
    scheme = ClassScheme.new
    assert_nil(scheme.outputs.first)
    scheme.outputs << { :host => "192.168.1.8" }
    assert_equal("192.168.1.8", scheme.outputs.first[:host])      
  end
  
end