#!/usr/bin/env ruby

require 'helper'

class EmitterTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper

  def test_client_initialized
    port = TestHelper.next_port
    e = Emitter.new
    e.add_client("1.1.1.2", port)
    assert_not_nil(e.clients.last)    
  end
  
  def test_two_clients
    port1 = TestHelper.next_port
    port2 = TestHelper.next_port
    e1 = Emitter.new
    e1.add_client("1.1.1.1", port1)
    client1 = e1.clients.last     
    e2 = Emitter.new
    e2.add_client("1.1.1.2", port2)
    client2 = e2.clients.last
    assert_equal(1, e1.clients.size)
    assert_equal(1, e2.clients.size)
    assert_not_equal(client1, client2)    
  end
  
  def test_two_clients_same_ip
    port1 = TestHelper.next_port
    port2 = TestHelper.next_port
    e1 = Emitter.new
    e1.add_client("1.1.1.1", port1)
    client1 = e1.clients.last   
    e2 = Emitter.new  
    e2.add_client("1.1.1.1", port2)
    client2 = e2.clients.last      
    assert_not_equal(client1, client2)    
  end
  
  def test_share_client
    port = TestHelper.next_port
    e1 = Emitter.new
    e1.add_client("1.1.1.1", port)
    client1 = e1.clients.last     
    e2 = Emitter.new 
    e2.add_client("1.1.1.1", port)
    client2 = e2.clients.last      
    assert_equal(client1, client2)
  end
  
  def test_transmit
    received = nil
    port = TestHelper.next_port
    
    e = Emitter.new
    e.add_client("localhost", port)
    @server = OSC::EMServer.new(port)
    @server.add_method("/test_transmit") do |message|
      received = message.args[0]
    end 
    Thread.new { @server.run }
    sleep(0.5)
    e.transmit(OSC::Message.new( "/test_transmit" , "hullo from io test_transmit!" ))
    sleep(0.5)
    assert_equal("hullo from io test_transmit!", received)
  end
  
end