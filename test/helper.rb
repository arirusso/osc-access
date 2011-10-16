#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'test/unit'
require 'osc-access'

module TestHelper
  
  class StubObject
    
    include OSCAccessible
    
  end
  
  $stub_object = StubObject.new 
     
end
