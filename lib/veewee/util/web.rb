module Veewee
  module Util
    class Web

      require 'webrick'
      include WEBrick

      class FileServlet < WEBrick::HTTPServlet::AbstractServlet

        def initialize(server,localfile)
          super(server)
          @server=server
          @localfile=localfile
        end
        def do_GET(request,response)
          response['Content-Type']='text/plain'
          #response['peeraddr']=["AF_INET", 55009, "10.100.1.100", "10.100.1.100"],
          response.status = 200
          puts "Serving file #{@localfile}"
          displayfile=File.open(@localfile,'r')
          content=displayfile.read()
          response.body=content
          #If we shut too fast it might not get the complete file
          sleep 2
          @server.shutdown
        end
      end

      def self.wait_for_request(filename,options={:timeout => 10, :web_dir => "", :port => 7125})

        # Calculate the OS equivalent of /dev/null , on windows this is NUL:
        # http://www.ruby-forum.com/topic/115472
        fn = test(?e, '/dev/null') ? '/dev/null' : 'NUL:'

        webrick_logger=WEBrick::Log.new(fn, WEBrick::Log::INFO)

        web_dir=options[:web_dir]
        filename=filename
        s= HTTPServer.new(
          :Port => options[:port],
          :Logger => webrick_logger,
          :AccessLog => webrick_logger
        )
        s.mount("/#{filename}", FileServlet,File.join(web_dir,filename))
        trap("INT"){
          s.shutdown
          puts "Stopping webserver"
          exit
        }
        s.start
      end

    end #Class
  end #Module
end #Module
