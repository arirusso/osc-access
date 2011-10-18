#!/usr/bin/env ruby

require 'helper'

class IOTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_server_initialized
    io = IO.new
    io.add_server(8000)
    assert_not_nil(io.servers.last)
  end
  
  def test_client_initialized
    io = IO.new
    io.add_server(8001)
    io.add_client("1.1.1.2", 9000)
    assert_not_nil(io.clients.last)    
  end
  
  def test_two_servers
    io1 = IO.new
    io1.add_server(8002)
    server1 = io1.servers.last
    io2 = IO.new
    io2.add_server(8003)
    server2 = io2.servers.last
    assert_not_equal(server1, server2)    
  end
  
  def test_two_clients
    io1 = IO.new
    io1.add_server(8004)
    io1.add_client("1.1.1.1", 9001)
    client1 = io1.clients.last     
    io2 = IO.new
    io2.add_server(8005)
    io2.add_client("1.1.1.2", 9002)
    client2 = io2.clients.last
    assert_not_equal(client1, client2)    
  end
  
  def test_two_clients_same_ip
    io1 = IO.new
    io1.add_server(8006)
    io1.add_client("1.1.1.1", 9003)
    client1 = io1.clients.last   
    io2 = IO.new
    io2.add_server(8007)   
    io2.add_client("1.1.1.1", 9004)
    client2 = io2.clients.last      
    assert_not_equal(client1, client2)    
  end
  
  def test_share_server
    #io1 = IO.new(:input_port => 8008)
    #server1 = io1.servers.last
    #io2 = IO.new(:input_port => 8008)
    #server2 = io2.servers.last
    #assert_equal(server1, server2)
  end
  
  def test_share_client
    io1 = IO.new
    io1.add_server(8009)
    io1.add_client("1.1.1.1", 9005)
    client1 = io1.clients.last     
    io2 = IO.new
    io2.add_server(8010)   
    io2.add_client("1.1.1.1", 9005)
    client2 = io2.clients.last      
    assert_equal(client1, client2)
  end
  
  def test_transmit
    received = nil
    io = IO.new
    io.add_server(9015)
    io.add_client("localhost", 4000)
    @server = OSC::EMServer.new(4000)
    @server.add_method("/test_transmit") do |message|
      received = message.args[0]
    end 
    Thread.new { @server.run }
    sleep(0.5)
    io.transmit(OSC::Message.new( "/test_transmit" , "hullo from io/transmit!" ))
    sleep(0.5)
    assert_equal("hullo from io/transmit!", received)
  end
  
  def test_receive
    received = nil
    obj = StubObject.new
    io = IO.new
    io.add_server(3339)
    io.receive(obj, "/test_receive") do |obj, val|
      received = val
    end
    client = OSC::Client.new( 'localhost', 3339 )
    client.send( OSC::Message.new( "/test_receive" , "hullo from io/receive!" ))
    sleep(0.5)    
    assert_equal("hullo from io/receive!", received)
  end
  
end