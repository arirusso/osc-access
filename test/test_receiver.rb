#!/usr/bin/env ruby

require 'helper'

class ReceiverTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_server_initialized
    io = Receiver.new
    port = TestHelper.next_port
    
    io.add_server(port)
    assert_not_nil(io.servers.values.last)
  end
  
  def test_two_servers
    port1 = TestHelper.next_port
    port2 = TestHelper.next_port
    
    io1 = Receiver.new
    io1.add_server(port1)
    server1 = io1.servers.values.last
    io2 = Receiver.new
    io2.add_server(port2)
    server2 = io2.servers.values.last
    assert_equal(1, io1.servers.size)
    assert_equal(1, io2.servers.size)
    assert_not_equal(server1, server2)    
  end
  
  def test_share_server
    #io1 = Receiver.new(:input_port => 8008)
    #server1 = io1.servers.last
    #io2 = Receiver.new(:input_port => 8008)
    #server2 = io2.servers.last
    #assert_equal(server1, server2)
  end
  
  def test_receive
    received = nil
    obj = StubObject.new
    io = Receiver.new
    port = TestHelper.next_port
    
    io.add_server(port)
    io.add_receiver(obj, "/test_receive") do |obj, val|
      received = val
    end
    sleep(0.5)
    client = OSC::Client.new( 'localhost', port )
    client.send( OSC::Message.new( "/test_receive" , "hullo from io test_receive!" ))
    sleep(0.5)    
    assert_equal("hullo from io test_receive!", received)
  end
  
end