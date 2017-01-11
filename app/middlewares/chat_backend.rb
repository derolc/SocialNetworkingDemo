# app/middleware/websockets.rb

require 'faye/websocket'

class ChatBackend

  KEEPALIVE_TIME = 15
  attr_reader :clients, :base_channel

  def initialize(app)
    @app = app
    # An array to hold all connected clients
    @clients = []
    # A base channel name used for pattern matching in Redis
    @base_channel = 'websockets'
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)
      # If the type of connection we're dealing with is a weboscket request, handle the connection.
      setup_websocket_connection(env)
    else
      # Normal requests will continue through the call chain.
      @app.call(env)
    end
  end

  def new_client
    # A client is represented here as a hash that has access to the Faye::Websocket  object and an array of channels they care about.
    {:ws => nil, :channels => []}
  end

  def setup_websocket_connection(env)
    ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME})
    # Create a new client
    client = new_client

    request = Rack::Request.new(env)
    channel_name = request.path_info.split('/').pop

    # When a connection has been opened
    ws.on :open do |event|
      # Assign the websocket object to the client
      client[:ws] = ws
      client[:channels].push(channel_name)

      # Add the client to the list of clients
      clients.push(client)
    end

    ws.on :message do |event|
      channel_name = request.path_info.split('/').pop
      timestamp = Time.now.utc
      message, sender = event.data.split('|~|')

      clients.each do |cl|
        # If the client has requested a subscription to this channel
        if cl[:channels].include?(channel_name)
          chat_message = "{\"message\":\"#{message}\",\"timestamp\":\"#{timestamp}\",\"sender\":\"#{User.find(sender).name}\"}"
          cl[:ws].send(chat_message)
        end
      end
    end

    ws.on :close do |event|
      # Remove them from our list
      clients.delete(client)
      ws = nil
    end


    # Return the websocket rack response
    ws.rack_response
  end

end
