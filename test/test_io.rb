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
    io = IO.new(:input_port => 8000, :output => { :port => 9000, :host => "1.1.1.2" })
    assert_not_nil(io.clients.last)    
  end
  
  def test_two_servers
    io1 = IO.new(:input_port => 8001)
    server1 = io1.servers.last
    io2 = IO.new(:input_port => 8002)
    server2 = io2.servers.last
    assert_not_equal(server1, server2)    
  end
  
  def test_two_clients
    io1 = IO.new(:input_port => 8000, :output => { :port => 9002, :host => "1.1.1.1" })
    client1 = io1.clients.last     
    io2 = IO.new(:input_port => 8000, :output => { :port => 9003, :host => "1.1.1.2" })
    client2 = io2.clients.last
    assert_not_equal(client1, client2)    
  end
  
  def test_two_clients_same_ip
    io1 = IO.new(:input_port => 8000, :output => { :port => 9002, :host => "1.1.1.1" })
    client1 = io1.clients.last      
    io2 = IO.new(:input_port => 8000, :output => { :port => 9003, :host => "1.1.1.1" })
    client2 = io2.clients.last      
    assert_not_equal(client1, client2)    
  end
  
  def test_share_server
    io1 = IO.new(:input_port => 8001)
    server1 = io1.servers.last
    io2 = IO.new(:input_port => 8001)
    server2 = io2.servers.last
    assert_equal(server1, server2)
  end
  
  def test_share_client
    io1 = IO.new(:input_port => 8000, :output => { :port => 9000, :host => "1.1.1.1" })
    client1 = io1.clients.last     
    io2 = IO.new(:input_port => 8000, :output => { :port => 9000, :host => "1.1.1.1" })
    client2 = io2.clients.last      
    assert_equal(client1, client2)
  end
  
  def test_transmit
    received = nil
    @server = OSC::EMServer.new(3334)
    @server.add_method("/greeting") do |message|
      received = message.args[0]
    end
    Thread.new { @server.run }
    io = IO.new(:output => { :port => 3334, :host => "localhost" })
    io.transmit(OSC::Message.new( "/greeting" , "hullo!" ))
    sleep(0.5)
    assert_equal("hullo!", received)
  end
  
  def test_receive
    received = nil
    io = IO.new(:input_port => 3333)
    io.receive(io, "/greeting") do |obj, message|
      received = message.args[0]
    end
    io.start
    client = OSC::Client.new( 'localhost', 3333 )
    client.send( OSC::Message.new( "/greeting" , "hullo!" ))
    sleep(0.5)    
    assert_equal("hullo!", received)
  end
  
end