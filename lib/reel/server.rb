module Reel
  class Server
    include Celluloid::IO

    # How many connections to backlog in the TCP accept queue
    DEFAULT_BACKLOG = 100

    execute_block_on_receiver :initialize
    finalizer :shutdown

    def initialize(host, port, backlog = DEFAULT_BACKLOG, &callback)
      # This is actually an evented Celluloid::IO::TCPServer

      @server = TCPServer.new(host, port)
      @server.listen(backlog)
      @callback = callback
      async.run

      # TODO: Catch Errno::EADDRINUSE and kill overall process, even if supervised.

    end

    def shutdown
      @server.close if @server
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def handle_connection(socket)
      connection = Connection.new(socket)
      optimize_socket socket
      begin
        @callback.call(connection)
      ensure
        if connection.attached?
          connection.close rescue nil
        end
      end
    rescue RequestError, EOFError
      deoptimize_socket
      # Client disconnected prematurely
      # TODO: log this?
    end

    if RUBY_PLATFORM =~ /linux/
      def optimize_socket(socket)
        if socket.kind_of? TCPSocket
          socket.setsockopt( Socket::IPPROTO_TCP, :TCP_NODELAY, 1 )
          socket.setsockopt( Socket::IPPROTO_TCP, 3, 1 ) # TCP_CORK
          socket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
        end
      end

      def deoptimize_socket(socket)
        socket.setsockopt(6, 3, 0) if socket.kind_of? TCPSocket
      end
    else
      def optimize_socket(socket)
      end

      def deoptimize_socket(socket)
      end
    end
  end
end
