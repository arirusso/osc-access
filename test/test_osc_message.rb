#!/usr/bin/env ruby

require 'helper'

class OSCObjectTest < Test::Unit::TestCase

  include OSCObject
  include TestHelper
  
  def test_osc_message
    m = OSC::Message.new("/blah", "hullo!")
    assert_equal("hullo!", m.args.first)
  end
  
end