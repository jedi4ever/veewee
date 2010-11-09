require 'webrick'
include WEBrick

class FileServlet < WEBrick::HTTPServlet::AbstractServlet
        def do_GET(request,response)
                response['Content-Type']='text/plain'
                response.status = 200
                displayfile=File.open("/Users/patrick/vagrantbox/files/preseed.cfg",'r')
                content=displayfile.read()
                response.body=content
                sleep 4
                @@s.shutdown
        end
end

@@s= HTTPServer.new(:Port => 7125)
@@s.mount("/preseed.cfg", FileServlet)
trap("INT"){@@s.shutdown}
@@s.start
