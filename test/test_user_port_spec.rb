#!/usr/bin/env ruby

require 'helper'

class UserPortSpecTest < Test::Unit::TestCase

  include OSCObject
  include TestHelper
  
  def test_hash
    spec = UserPortSpec.new({ :receive => 8006, :send => 9006 })
    assert_equal(8006, spec.receive)
    assert_equal(9006, spec.transmit)       
  end
  
  def test_numeric
    scheme = ClassScheme.new
    spec = UserPortSpec.new 8007
    assert_equal(8007, spec.receive)
    assert_nil(spec.transmit)       
  end
  
end