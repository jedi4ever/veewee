class RbVmomi::VIM::Datastore

  def upload remote_path, local_path
    err "local file does not exist" unless File.exists? local_path
    upload_path = mkuripath remote_path 

    _http_upload _connection, local_path, upload_path
  end

  def mkdir path
    _connection.serviceContent.fileManager.MakeDirectory :name=>mkdsuripath(path),
                                                         :createParentDirectories => false
  end

  def mkdsuripath path
    http = _connection.http
    return "https://#{http.address}:#{http.port}#{mkuripath(path)}"
  end

  def _http_clone main_http
    http = Net::HTTP.new(main_http.address, main_http.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #http.set_debug_output $stderr
    http.start
    err "certificate mismatch" unless main_http.peer_cert.to_der == http.peer_cert.to_der
    return http
  end

  def _http_upload connection, local_path, http_path
    err "local file does not exist" unless File.exists? local_path

    http = _http_clone connection.http

    File.open(local_path, 'rb') do |io|
      stream = ProgressStream.new(io, io.stat.size) do |s|
        $stdout.write "\e[0G\e[Kuploading #{s.count}/#{s.len} bytes (#{(s.count*100)/s.len}%)"
        $stdout.flush
      end

      headers = {
        'cookie' => connection.cookie,
        'content-length' => io.stat.size.to_s,
        'Content-Type' => 'application/octet-stream',
      }

      request = Net::HTTP::Put.new http_path, headers
      request.body_stream = stream
      res = http.request(request)
      $stdout.puts
      case res
      when Net::HTTPOK
      else
        err "upload failed: #{res.message}"
      end
    end
  end

  class ProgressStream
    attr_reader :io, :len, :count

    def initialize io, len, &b
      @io = io
      @len = len
      @count = 0
      @cb = b
    end

    def read n
      io.read(n).tap do |c|
        @count += c.length if c
        @cb[self]
      end
    end
  end
end


