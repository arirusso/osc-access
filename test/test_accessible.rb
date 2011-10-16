#!/usr/bin/env ruby

require 'helper'

class AccessibleTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_osc_analog
    outp = StubObject.new.send(:osc_analog, 0.8, :local => 0..127, :remote => 0..1)
    assert_equal(101, outp)      
  end
  
  def test_osc_analog_default_remote
    outp = StubObject.new.send(:osc_analog, 0.5, 0..127)
    assert_equal(63, outp)      
  end
  
  def test_osc_analog_float
    outp = StubObject.new.send(:osc_analog, 12, :remote => 0..120, :local => 0..1, :type => :float)
    assert_equal(0.10, outp)     
  end
  
  def test_osc_output
    
  end
  
  def test_osc_input
    
  end
  
  #def test_change_receive_port
  #  
  #end
  
  #def test_change_transmit_port
  #  
  #end

  #def test_change_transmit_ip
  #  
  #end
  
  def test_load_map
    
  end
  
  def test_add_map_row
    
  end
    
  def test_class_included
    o = StubObject.new
    assert_equal(true, o.class.kind_of?(OSCAccess::Class))
  end

  def test_osc_accessor
    
  end
  
  def test_osc_writer_no_read
    received = nil
    
    server = OSC::EMServer.new(9053)
    server.add_method("/test_osc_writer_no_read") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    
    obj = StubObject.new
    obj.osc_start(:input_port => 8057, :output => { :port => 9053, :host => "localhost" })
    #obj.osc_writer(:data, :pattern => "/test_osc_writer_no_read")
    #obj.osc_start

    sleep(0.5)
    c = OSC::Client.new( 'localhost', 8057 )
    c.send( OSC::Message.new( "/test_osc_writer_no_read", "a value!"))
    sleep(0.5)
    
    assert_nil(received)     
  end
  
  def test_osc_reader_no_write
    obj = StubObject.new
    obj.osc_start(:input_port => 9052)
    obj.osc_reader(:data, :pattern => "/osc_reader_no_write_test")
    sleep(0.5)    
    client = OSC::Client.new( 'localhost', 9052 )
    client.send( OSC::Message.new( "/osc_reader_no_write_test" , "hullo from test_osc_reader_no_write!" ))
    sleep(0.5)
    assert_nil(obj.data)       
  end
  
  def test_osc_reader
    sleep(1)
    received = nil
    
    server = OSC::EMServer.new(9051)
    server.add_method("/osc_reader_test") do |message|
      received = message.args[0]
    end 
    Thread.new { server.run }
    
    obj = StubObject.new
    obj.data = "testing reader!"
    obj.osc_start(:input_port => 8050, :output => { :port => 9051, :host => "localhost" })
    obj.osc_reader(:data, :pattern => "/osc_reader_test")
    obj.osc_start

    sleep(0.5)
    client = OSC::Client.new( 'localhost', 8050 )
    client.send( OSC::Message.new( "/osc_reader_test"))
    sleep(0.5)
    
    assert_equal("testing reader!", received)       
  end
  
  def test_osc_writer
    obj = StubObject.new
    obj.osc_start(:input_port => 9050)
    obj.osc_writer(:data, :pattern => "/greeting")
    sleep(0.5)    
    client = OSC::Client.new( 'localhost', 9050 )
    client.send( OSC::Message.new( "/greeting" , "hullo from osc_writer!" ))
    sleep(0.5)
    assert_equal("hullo from osc_writer!", obj.data)    
  end

  def test_osc_receive
    
  end
  
  def test_osc_send
    
  end
  
  def test_osc_send_attr
    
  end

  def test_osc_start
    
  end

  def test_override_attr_accessor
    
  end
  
  def test_get_arg
    
  end

  def test_set_local_value
    
  end
  
end