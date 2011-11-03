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
  
  def test_osc_send
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    server = OSC::EMServer.new(port)
    server.add_method("/test_osc_output") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_output(:port => port, :host => "localhost")
    obj.osc_send("/test_osc_output", "hi friend")
    sleep(0.5)
    assert_equal("hi friend", received)
  end
    
  def test_osc_send_msg
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    server = OSC::EMServer.new(port)
    server.add_method("/test_osc_output") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_output(:port => port, :host => "localhost")
    obj.osc_send(OSC::Message.new("/test_osc_output", "hi friend"))
    sleep(0.5)
    assert_equal("hi friend", received)
  end
  
  def test_osc_send_accessor_translate
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    server = OSC::EMServer.new(port)
    server.add_method("/test_osc_send_accessor_translate") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_receive("/test_osc_send_accessor_translate", :accessor => :data, :translate => 0..127)
    obj.osc_output(:port => port, :host => "localhost")
    obj.data = 63
    obj.osc_send(:data)
    sleep(0.5)
    assert_equal(0.5, received.round(1))
  end
  
  def test_osc_send_accessor
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    server = OSC::EMServer.new(port)
    server.add_method("/test_osc_send_accessor") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_receive("/test_osc_send_accessor", :accessor => :data)
    obj.osc_output(:port => port, :host => "localhost")
    obj.data = "blahblah"
    obj.osc_send(:data)
    sleep(0.5)
    assert_equal("blahblah", received)
  end
    
  def test_osc_input
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    obj = StubObject.new
    
    obj.osc_input(port)
    obj.osc_start
    obj.osc_receive("/test_osc_input") do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_osc_input", "hullo from test_osc_input!"))  
    sleep(0.5)
    assert_equal("hullo from test_osc_input!", received)  
  end
  
  def test_osc_process_ports_args
    obj = StubObject.new
    assert_equal([8000], obj.send(:osc_process_ports_args, [8000]))
    assert_equal([8000], obj.send(:osc_process_ports_args, [[8000]]))
    assert_equal((8000..8010).to_a, obj.send(:osc_process_ports_args, [8000..8010]))
    assert_equal((8000..8010).to_a, obj.send(:osc_process_ports_args, [[8000..8010]]))
    assert_equal([8000], obj.send(:osc_process_ports_args, [:port => 8000]))
  end
  
  
  def test_osc_receive_translate
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    obj = StubObject.new
    obj.osc_start(:input_port => port)
    obj.osc_receive("/test_osc_receive_translate", :translate => 0..127) do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_osc_receive_translate", 0.5))  
    sleep(0.5)
    assert_equal(63, received)  
  end
  
  def test_osc_receive_arg
    sleep(0.5)
    received = nil
    port = TestHelper.next_port
    
    obj = StubObject.new
    obj.osc_start(:input_port => port)
    obj.osc_receive("/test_osc_receive_arg", :arg => 1) do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_osc_receive_arg",5,4,3,2,1))  
    sleep(0.5)
    assert_equal(4, received)  
  end  
  
  def test_osc_receive_accessor
    sleep(0.5)
    port = TestHelper.next_port
    obj = StubObject.new
    
    obj.osc_start(:input_port => port)
    obj.osc_receive("/test_osc_receive_accessor", :accessor => :data)
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_osc_receive_accessor", "hi from test_osc_receive_accessor"))  
    sleep(0.5)
    assert_equal("hi from test_osc_receive_accessor", obj.data)  
  end  
  
  def test_load_map_inline_proc
    received = nil
    port = TestHelper.next_port
    map = {
      "/test_load_map_inline_proc" => Proc.new do |instance, val| 
          received = val
        end
    }
    obj = StubObject.new
    obj.osc_input(port)
    obj.osc_start
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_load_map_inline_proc", "hullo from test_load_map_inline_proc!"))  
    sleep(0.5)
    assert_equal("hullo from test_load_map_inline_proc!", received)  
  end
  
  def test_load_map
    received = nil
    port = TestHelper.next_port
    map = {
      "/test_load_map" => { 
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(port)
    obj.osc_start
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_load_map", "hullo from test_load_map!"))  
    sleep(0.5)
    assert_equal("hullo from test_load_map!", received)  
  end
  
  def test_load_map_translate
    received = nil
    port = TestHelper.next_port
    map = {
      "/test_load_map_translate" => { 
        :translate => 0..127,
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(port)
    obj.osc_start
    obj.osc_load_map(map)
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_load_map_translate", 0.5) ) 
    sleep(0.5)
    assert_equal(63, received)  
  end
  
  def test_load_map_arg
    received = nil
    port = TestHelper.next_port
    map = {
      "/test_load_map_arg" => { 
        :arg => 2,
        :action => Proc.new do |instance, val| 
          received = val
        end
      }
    }
    obj = StubObject.new
    obj.osc_input(port)
    obj.osc_load_map(map)
    obj.osc_start
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_load_map_arg",0,1,2,3,4) ) 
    sleep(0.5)
    assert_equal(2, received)  
  end
    
  def test_class_included
    o = StubObject.new
    assert_equal(true, o.class.kind_of?(OSCAccess::Class))
  end
  
  def test_osc_receive_thru
    sleep(0.5)
    received, received_back = nil, nil
    port1 = TestHelper.next_port
    port2 = TestHelper.next_port
    server = OSC::EMServer.new(port1)
    server.add_method("/test_osc_receive_thru") do |message|
      received_back = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_start(:input_port => port2, :output => { :host => "localhost", :port => port1 })
    obj.osc_receive("/test_osc_receive_thru", :thru => true) do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", port2)
    client.send( OSC::Message.new( "/test_osc_receive_thru", "hullo from test_osc_receive_thru!"))  
    sleep(0.5)
    assert_equal("hullo from test_osc_receive_thru!", received)  
    assert_equal("hullo from test_osc_receive_thru!", received_back)       
  end

  def test_osc_start_input
    sleep(1)
    received = nil
    port = TestHelper.next_port
    obj = StubObject.new
    
    obj.osc_start(:input_port => port)
    obj.osc_receive("/test_osc_start_input") do |obj, val|
      received = val
    end
    client = OSC::Client.new("localhost", port)
    client.send( OSC::Message.new( "/test_osc_start_input", "hullo from test_osc_start_input!"))  
    sleep(0.5)
    assert_equal("hullo from test_osc_start_input!", received)      
  end
  
  def test_osc_multiplex_input
    sleep(1)
    received = 0 
    
    obj = StubObject.new
    obj.osc_start(:input_port => 9080..9082)
    obj.osc_receive("/test_osc_multiplex_input") do |obj, val|
      received += 1
    end
    sleep(0.5)
    3.times do |i|
      client = OSC::Client.new("localhost", 9080 + i)
      client.send( OSC::Message.new( "/test_osc_multiplex_input", i))  
    end
    sleep(0.5)
    assert_equal(3, received)      
  end
  
  def test_osc_start_output
    sleep(1)
    received = nil
    port = TestHelper.next_port
    
    server = OSC::EMServer.new(port)
    server.add_method("/test_osc_start_output") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    sleep(0.5)
    obj = StubObject.new
    obj.osc_start(:output => { :port => port, :host => "localhost" })
    obj.osc_send("/test_osc_start_output", "hi from test_osc_start_output")
    sleep(0.5)
    assert_equal("hi from test_osc_start_output", received)    
  end
  
end