#!/usr/bin/env ruby

require 'helper'

class AccessibleTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_osc_translate
    outp = StubObject.new.send(:osc_translate, 0.8, :local => 0..127, :remote => 0..1)
    assert_equal(101, outp)      
  end
  
  def test_osc_translate_default_remote
    outp = StubObject.new.send(:osc_translate, 0.5, 0..127)
    assert_equal(63, outp)      
  end
  
  def test_osc_translate_float
    outp = StubObject.new.send(:osc_translate, 12, :remote => 0..120, :local => 0..1, :type => :float)
    assert_equal(0.10, outp)     
  end
  
  def test_osc_output
    received = nil
    obj = StubObject.new
    obj.osc_output(:port => 8060, :host => "localhost")
    server = OSC::EMServer.new(8060)
    server.add_method("/test_osc_output") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    obj.osc_send_val("/test_osc_output", "hi friend")
    sleep(0.5)
    assert_equal("hi friend", received)
  end
    
  def test_osc_input
    received = nil
    obj = StubObject.new
    obj.osc_input(8061)
    obj.osc_receive("/test_osc_input") do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", 8061)
    client.send( OSC::Message.new( "/test_osc_input", "hullo from test_osc_input!"))  
    sleep(0.5)
    assert_equal("hullo from test_osc_input!", received)  
  end
  
  def test_osc_receive_translate
    received = nil
    obj = StubObject.new
    obj.osc_start(:input_port => 8061)
    obj.osc_receive("/test_osc_receive_translate", :translate => 0..127) do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", 8061)
    client.send( OSC::Message.new( "/test_osc_receive_translate", 0.5))  
    sleep(0.5)
    assert_equal(63, received)  
  end
  
  def test_osc_receive_arg
    received = nil
    obj = StubObject.new
    obj.osc_start(:input_port => 8061)
    obj.osc_receive("/test_osc_receive_arg", :arg => 1) do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", 8061)
    client.send( OSC::Message.new( "/test_osc_receive_arg",5,4,3,2,1))  
    sleep(0.5)
    assert_equal(4, received)  
  end  
  
  def test_load_map
    received = nil
    map = {
      "/test_load_map" => { 
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(8062)
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", 8062)
    client.send( OSC::Message.new( "/test_load_map", "hullo from test_load_map!"))  
    sleep(0.5)
    assert_equal("hullo from test_load_map!", received)  
  end
  
  def test_load_map_translate
    received = nil
    map = {
      "/test_load_map_translate" => { 
        :translate => 0..127,
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(8065)
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", 8065)
    client.send( OSC::Message.new( "/test_load_map_translate", 0.5) ) 
    sleep(0.5)
    assert_equal(63, received)  
  end
  
  def test_load_map_arg
    received = nil
    map = {
      "/test_load_map_arg" => { 
        :arg => 2,
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(8066)
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", 8066)
    client.send( OSC::Message.new( "/test_load_map_arg",0,1,2,3,4) ) 
    sleep(0.5)
    assert_equal(2, received)  
  end
    
  def test_class_included
    o = StubObject.new
    assert_equal(true, o.class.kind_of?(OSCAccess::Class))
  end

  def test_osc_start_input
    received = nil
    obj = StubObject.new
    obj.osc_start(:input_port => 8063)
    obj.osc_receive("/test_osc_start_input") do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", 8063)
    client.send( OSC::Message.new( "/test_osc_start_input", "hullo from test_osc_start_input!"))  
    sleep(0.5)
    assert_equal("hullo from test_osc_start_input!", received)      
  end
  
  def test_osc_start_output
    received = nil
    obj = StubObject.new
    obj.osc_start(:output => { :port => 8064, :host => "localhost" })
    server = OSC::EMServer.new(8064)
    server.add_method("/test_osc_start_output") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    obj.osc_send_val("/test_osc_start_output", "hi from test_osc_start_output")
    sleep(0.5)
    assert_equal("hi from test_osc_start_output", received)    
  end
  
end