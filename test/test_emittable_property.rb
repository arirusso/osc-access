#!/usr/bin/env ruby

require 'helper'

class EmittablePropertyTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_translate
    obj = StubObject.new
    obj.data = 101
    prop = EmittableProperty.new(:data, "pattern", :translate => { :local => 0..127, :remote => 0..1 })
    output = prop.value(obj)
    assert_equal(0.8, output.first.round(1))      
  end
  
end