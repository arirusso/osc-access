#!/usr/bin/env ruby

require 'helper'

class IOTest < Test::Unit::TestCase

  include OSCAccess
  include TestHelper
  
  def test_server_initialized
    io = IO.new(:input_port => 8000)
    assert_not_nil(io.servers.last)
  end
  
  def test_client_initialized
    io = IO.new(:input_port => 8001, :output => { :port => 9000, :host => "1.1.1.2" })
    assert_not_nil(io.clients.last)    
  end
  
  def test_two_servers
    io1 = IO.new(:input_port => 8002)
    server1 = io1.servers.last
    io2 = IO.new(:input_port => 8003)
    server2 = io2.servers.last
    assert_not_equal(server1, server2)    
  end
  
  def test_two_clients
    io1 = IO.new(:input_port => 8004, :output => { :port => 9001, :host => "1.1.1.1" })
    client1 = io1.clients.last     
    io2 = IO.new(:input_port => 8005, :output => { :port => 9002, :host => "1.1.1.2" })
    client2 = io2.clients.last
    assert_not_equal(client1, client2)    
  end
  
  def test_two_clients_same_ip
    io1 = IO.new(:input_port => 8006, :output => { :port => 9003, :host => "1.1.1.1" })
    client1 = io1.clients.last      
    io2 = IO.new(:input_port => 8007, :output => { :port => 9004, :host => "1.1.1.1" })
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
    io1 = IO.new(:input_port => 8009, :output => { :port => 9005, :host => "1.1.1.1" })
    client1 = io1.clients.last     
    io2 = IO.new(:input_port => 8010, :output => { :port => 9005, :host => "1.1.1.1" })
    client2 = io2.clients.last      
    assert_equal(client1, client2)
  end
  
  def test_transmit
    received = nil
    io = IO.new(:input_port => 9015, :output => { :port => 4000, :host => "localhost" })
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
    io = IO.new(:input_port => 3339)
    io.receive(obj, "/test_receive") do |obj, val|
      received = val
    end
    client = OSC::Client.new( 'localhost', 3339 )
    client.send( OSC::Message.new( "/test_receive" , "hullo from io/receive!" ))
    sleep(0.5)    
    assert_equal("hullo from io/receive!", received)
  end
  
end