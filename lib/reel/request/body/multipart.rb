require 'multipart_parser/parser'
require 'multipart_parser/reader'

module Reel
  class Request

  	def multipart
  		@body.multipart.decoded
  	end

    class Body
     
   		include HeadersMixin

	    def multipart? body=nil
	    	return @multipart.is_a? Body::Multipart if body.nil? or !@multipart.nil?
				boundary = MultipartParser::Reader.extract_boundary_value @request.headers[CONTENT_TYPE]
				@multipart = Body::Multipart.new body, boundary if boundary
				_de "boundary: #{boundary}"
				return @multipart.is_a? Body::Multipart
			rescue => ex
				@multipart = false
	    end

	    class Multipart

		    extend Forwardable

		    def_delegators :@reader, :write, :part, :ended?

	      def initialize(body,boundary)
	      	@parts = {}
	      	@body = body
	      	@boundary = boundary
	      	@reader = MultipartParser::Reader.new(@boundary)
	      	@ended = false

		      @reader.on_part do |part|
		        part_entry = { :part => part, :data => '', :ended => false }
		        parts[part.name] = part_entry
		        part.on_data do |data|
		          part_entry[:data] << data
		        end
		        part.on_end do
		          part_entry[:ended] = true
		        end
		      end
	      end

	      def decoded
	      	return @parts if @parts.any?

		      #take the decoded, multipart body hash
		      def decoded
		        return @parts if @ended

		        begin
		          @body.each { |chunk|
		          	write chunk
		          }
		        rescue
		          @parts = {}
		          raise
		        end
						
						@parts #de unless not ended
		      end
	      end

	    end
	  end
  end
end