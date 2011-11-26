require 'socket'
require 'yaml'
require 'thread'
require 'cipher/des'
require 'net/vnc/version'

module Net
  #
  # The VNC class provides for simple rfb-protocol based control of
  # a VNC server. This can be used, eg, to automate applications.
  #
  # Sample usage:
  #
  #   # launch xclock on localhost. note that there is an xterm in the top-left
  #   Net::VNC.open 'localhost:0', :shared => true, :password => 'mypass' do |vnc|
  #		vnc.pointer_move 10, 10
  #		vnc.type 'xclock'
  #		vnc.key_press :return
  #   end
  #
  # = TODO
  #
  # * The server read loop seems a bit iffy. Not sure how best to do it.
  # * Should probably be changed to be more of a lower-level protocol wrapping thing, with the
  #   actual VNCClient sitting on top of that. all it should do is read/write the packets over
  #   the socket.
  #
  class VNC
    class PointerState
      attr_reader :x, :y, :button

      def initialize vnc
        @x = @y = @button = 0
        @vnc = vnc
      end

      # could have the same for x=, and y=
      def button= button
        @button = button
        refresh
      end

      def update x, y, button=@button
        @x, @y, @button = x, y, button
        refresh
      end

      def refresh
        packet = 0.chr * 6
        packet[0] = 5.chr
        packet[1] = button.chr
        packet[2, 2] = [x].pack 'n'
        packet[4, 2] = [y].pack 'n'
        @vnc.socket.write packet
      end
    end

    BASE_PORT = 5900 if BASE_PORT.nil?
    CHALLENGE_SIZE = 16 if CHALLENGE_SIZE.nil?
    DEFAULT_OPTIONS = {
      :shared => false,
      :wait => 0.1
    } if DEFAULT_OPTIONS.nil?

    if KEY_MAP.nil?
      keys_file = File.dirname(__FILE__) + '/../../data/keys.yaml'
      KEY_MAP = YAML.load_file(keys_file).inject({}) { |h, (k, v)| h.update k.to_sym => v }
      def KEY_MAP.[] key
        super or raise ArgumentError.new('Invalid key name - %s' % key)
      end
    end

    attr_reader :server, :display, :options, :socket, :pointer

    def initialize display=':0', options={}
      @server = '127.0.0.1'
      if display =~ /^(.*)(:\d+)$/
        @server, display = $1, $2
      end
      @display = display[1..-1].to_i
      @options = DEFAULT_OPTIONS.merge options
      @clipboard = nil
      @pointer = PointerState.new self
      @mutex = Mutex.new
      connect
      @packet_reading_state = nil
      @packet_reading_thread = Thread.new { packet_reading_thread }
    end

    def self.open display=':0', options={}
      vnc = new display, options
      if block_given?
        begin
          yield vnc
        ensure
          vnc.close
        end
      else
        vnc
      end
    end

    def port
      BASE_PORT + @display
    end

    def connect
      @socket = TCPSocket.open server, port
      unless socket.read(12) =~ /^RFB (\d{3}.\d{3})\n$/
        raise 'invalid server response'
      end
      @server_version = $1
      socket.write "RFB 003.003\n"
      data = socket.read(4)
      auth = data.to_s.unpack('N')[0]
      case auth
      when 0, nil
        raise 'connection failed'
      when 1
        # ok...
      when 2
        password = @options[:password] or raise 'Need to authenticate but no password given'
        challenge = socket.read CHALLENGE_SIZE
        response = Cipher::DES.encrypt password, challenge
        socket.write response
        ok = socket.read(4).to_s.unpack('N')[0]
        raise 'Unable to authenticate - %p' % ok unless ok == 0
      else
        raise 'Unknown authentication scheme - %d' % auth
      end

      # ClientInitialisation
      socket.write((options[:shared] ? 1 : 0).chr)

      # ServerInitialisation
      # TODO: parse this.
      socket.read(20)
      data = socket.read(4)
      # read this many bytes in chunks of 20
      size = data.to_s.unpack('N')[0]
      while size > 0
        len = [20, size].min
        # this is the hostname, and other stuff i think...
        socket.read(len)
        size -= len
      end
    end

    # this types +text+ on the server
    def type text, options={}
      packet = 0.chr * 8
      packet[0] = 4.chr
      text.split(//).each do |char|
        packet[7] = char[0]
        packet[1] = 1.chr
        socket.write packet
        packet[1] = 0.chr
        socket.write packet
      end
      wait options
    end

    SHIFTED_CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ~!@#$%^&*()_+{}|:"<>?'
    KEY_PRESS_CHARS = {
      "\n" => :return,
      "\t" => :tab
    }

    # This types +text+ on the server, but it holds the shift key down when necessary.
    # It will also execute key_press for tabs and returns.
    def type_string text, options={}
      shift_key_down = nil

      text.each_char do |char|
        key_to_press = KEY_PRESS_CHARS[char]
        unless key_to_press.nil?
          key_press key_to_press
        else
          key_needs_shift = SHIFTED_CHARS.include? char

          if shift_key_down.nil? || shift_key_down != key_needs_shift
            if key_needs_shift
              key_down :shift
            else
              key_up :shift
            end
          end

          type char
          shift_key_down = key_needs_shift
        end
      end
      wait options
    end

    # this takes an array of keys, and successively holds each down then lifts them up in
    # reverse order.
    # FIXME: should wait. can't recurse in that case.
    def key_press(*args)
      options = Hash === args.last ? args.pop : {}
      keys = args
      raise ArgumentError, 'Must have at least one key argument' if keys.empty?
      begin
        key_down keys.first
        if keys.length == 1
          yield if block_given?
        else
          key_press(*(keys[1..-1] + [options]))
        end
      ensure
        key_up keys.first
      end
    end

    def get_key_code which
      if String === which
        if which.length != 1
          raise ArgumentError, 'can only get key_code of single character strings'
        end
        which[0]
      else
        KEY_MAP[which]
      end
    end
    private :get_key_code

    def key_down which, options={}
      packet = 0.chr * 8
      packet[0] = 4.chr
      key_code = get_key_code which
      packet[4, 4] = [key_code].pack('N')
      packet[1] = 1.chr
      socket.write packet
      wait options
    end

    def key_up which, options={}
      packet = 0.chr * 8
      packet[0] = 4.chr
      key_code = get_key_code which
      packet[4, 4] = [key_code].pack('N')
      packet[1] = 0.chr
      socket.write packet
      wait options
    end

    def pointer_move x, y, options={}
      # options[:relative]
      pointer.update x, y
      wait options
    end

    BUTTON_MAP = {
      :left => 0
    } if BUTTON_MAP.nil?

    def button_press button=:left, options={}
      begin
        button_down button, options
        yield if block_given?
      ensure
        button_up button, options
      end
    end

    def button_down which=:left, options={}
      button = BUTTON_MAP[which] || which
      raise ArgumentError, 'Invalid button - %p' % which unless (0..2) === button
      pointer.button |= 1 << button
      wait options
    end

    def button_up which=:left, options={}
      button = BUTTON_MAP[which] || which
      raise ArgumentError, 'Invalid button - %p' % which unless (0..2) === button
      pointer.button &= ~(1 << button)
      wait options
    end

    def wait options={}
      sleep options[:wait] || @options[:wait]
    end

    def close
      # destroy packet reading thread
      if @packet_reading_state == :loop
        @packet_reading_state = :stop
        while @packet_reading_state
          # do nothing
        end
      end
      socket.close
    end

    def clipboard
      if block_given?
        @clipboard = nil
        yield
        60.times do
          clipboard = @mutex.synchronize { @clipboard }
          return clipboard if clipboard
          sleep 0.5
        end
        warn 'clipboard still empty after 30s'
        nil
      else
        @mutex.synchronize { @clipboard }
      end
    end

    private

    def read_packet type
      case type
      when 3 # ServerCutText
        socket.read 3 # discard padding bytes
        len = socket.read(4).unpack('N')[0]
        @mutex.synchronize { @clipboard = socket.read len }
      else
        raise NotImplementedError, 'unhandled server packet type - %d' % type
      end
    end

    def packet_reading_thread
      @packet_reading_state = :loop
      loop do
        begin
          break if @packet_reading_state != :loop
          next unless IO.select [socket], nil, nil, 2
          type = socket.read(1)[0]
          read_packet type
        rescue
          warn "exception in packet_reading_thread: #{$!.class}:#{$!}"
          break
        end
      end
      @packet_reading_state = nil
    end
  end
end

