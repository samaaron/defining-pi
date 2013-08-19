require 'helper'
require 'integration/shared_examples'

describe "draft13" do
  include EM::SpecHelper
  default_timeout 1

  before :each do
    @request = {
      :port => 80,
      :method => "GET",
      :path => "/demo",
      :headers => {
        'Host' => 'example.com',
        'Upgrade' => 'websocket',
        'Connection' => 'Upgrade',
        'Sec-WebSocket-Key' => 'dGhlIHNhbXBsZSBub25jZQ==',
        'Sec-WebSocket-Protocol' => 'sample',
        'Sec-WebSocket-Origin' => 'http://example.com',
        'Sec-WebSocket-Version' => '13'
      }
    }

    @response = {
      :protocol => "HTTP/1.1 101 Switching Protocols\r\n",
      :headers => {
        "Upgrade" => "websocket",
        "Connection" => "Upgrade",
        "Sec-WebSocket-Accept" => "s3pPLMBiTxaQ9kYGzzhZRbK+xOo=",
      }
    }
  end

  it_behaves_like "a websocket server" do
    def start_server
      EM::WebSocket.start(:host => "0.0.0.0", :port => 12345) { |ws|
        yield ws
      }
    end

    def start_client
      client = EM.connect('0.0.0.0', 12345, Draft07FakeWebSocketClient)
      client.send_data(format_request(@request))
      yield client if block_given?
    end
  end

  it "should send back the correct handshake response" do
    em {
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 12345) { }

      # Create a fake client which sends draft 13 handshake
      connection = EM.connect('0.0.0.0', 12345, Draft07FakeWebSocketClient)
      connection.send_data(format_request(@request))

      connection.onopen {
        connection.handshake_response.lines.sort.
          should == format_response(@response).lines.sort
        done
      }
    }
  end

  # TODO: This test would be much nicer with a real websocket client...
  it "should support sending pings and binding to onpong" do
    em {
      EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 12345) { |ws|
        ws.onopen {
          ws.should be_pingable
          EM.next_tick {
            ws.ping('hello').should == true
          }

        }
        ws.onpong { |data|
          data.should == 'hello'
          done
        }
      }

      # Create a fake client which sends draft 13 handshake
      connection = EM.connect('0.0.0.0', 12345, Draft07FakeWebSocketClient)
      connection.send_data(format_request(@request))

      # Confusing, fake onmessage means any data after the handshake
      connection.onmessage { |data|
        # This is what a ping looks like
        data.should == "\x89\x05hello"
        # This is what a pong looks like
        connection.send_data("\x8a\x05hello")
      }
    }
  end
end
