#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'test/unit'
require 'osc-object'

module TestHelper
  
  class StubObject
    
    include OSCObject::Node
    
  end
  
  $stub_object = StubObject.new 
     
end
