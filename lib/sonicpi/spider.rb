require_relative "util"
require_relative "studio"
require_relative "incomingevents"
require_relative "counter"
require_relative "promise"
require_relative "spmidi"
require 'chunky_png'

require 'thread'
require 'fileutils'

module SonicPi
  class Spider
    include SonicPi::SPMIDI
    attr_reader :event_queue

    def initialize(hostname, port, msg_queue, max_concurrent_synths)
      @studio = Studio.new(hostname, port, msg_queue, max_concurrent_synths)
      @msg_queue = msg_queue
      @event_queue = Queue.new
      @keypress_handlers = {}
      @pngs = {}
      message "Starting..."
      @events = IncomingEvents.new
      @sync_counter = Counter.new
      Thread.new do
        loop do
          event = @event_queue.pop
          handle_event event
        end
      end
    end

    def sync(id)
      @events.event("/sync", {:id => id})
    end

    def handle_event(e)
      case e[:type]
      when :keypress
        @keypress_handlers.values.each{|h| h.call(e)}
        else
          puts "Unknown event: #{e}"
        end
    end

    def on_keypress(&block)
      @keypress_handlers[:foo] = block
    end

    def message(s)
      @msg_queue.push({:type => :message, :val => s.to_s})
    end

    def sync_msg_command(msg)
      id = @sync_counter.next
      prom = Promise.new
      @events.add_handler("/sync", @events.gensym("/spider")) do |payload|
        if payload[:id] == id
          prom.deliver! true
          :remove_handler
        end
      end
      msg[:sync] = id
      @msg_queue.push msg
      prom.get
    end

    def with_synth(synth_name)
      @studio.current_synth_name = synth_name
    end

    def play_synth(synth_name, *args)
      message "playing #{synth_name} with: #{args}"
      STDOUT.flush
      STDOUT.flush
      @studio.trigger_synth synth_name, *args
    end

    def play(note, *args)
      play_synth @studio.current_synth_name, "note", note, *args
    end

    def repeat(&block)
      while true
        block.call
      end
    end

    def with_tempo(n)
      @studio.bpm = n
    end

    def play_pattern(notes, *args)
      notes.each{|note| play(note, *args) ; sleep(@studio.beat_s)}
    end

    def play_pattern_timed(notes, times, *args)
      notes.each_with_index{|note, idx| play(note, *args) ; sleep(times[idx % times.size])}
    end

    def play_chord(notes, *args)
      notes.each{|note| play(note, *args)}
    end

    def stop
      message "Stopping..."
      @studio.stop
    end

    def play_pad(name, *args)
      if args.size == 1
        @studio.switch_to_pad(name, "note", args[0])
      else
        @studio.switch_to_pad(name, *args)
      end
    end

    def control_pad(*args)
      @studio.control_pad(*args)
    end

    def comms_eval(code)
      eval(code)
      STDOUT.flush
      STDOUT.flush
      Thread.list.map {|t| t.join 60}
    end

    def debug!
      @studio.debug = true
    end

    def debug_off!
      @studio.debug = false
    end

    def in_thread(&block)
      Thread.new do
        with_synth "pretty_bell"
        block.call
      end
    end

    def with_volume(vol)
      if (vol < 0)
        @studio.volume = 0
      elsif (vol > 3)
        @studio.volume = 3
      else
        @studio.volume = vol
      end
    end

    def spider_eval(code)
      eval(code)
      STDOUT.flush
    end

    def print(output)
      message output
    end

    def puts(output)
      message output
    end

    def status
      message @studio.status
    end

    def png(width, height, id)
      p = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color::TRANSPARENT)
      @pngs[id] = p
      message "Created png with id: #{id} #{width}x#{height}"
    end

    def set_png_pixel(id, x, y, color)
      p = @pngs[id]
      raise "Can't find png with id #{id}" unless p

      red = color[:red] || 0
      green = color[:green] || 0
      blue = color[:blue] || 0
      alpha = color[:alpha] || 255
      p[x,y] = ChunkyPNG::Color.rgba(red, green, blue, alpha)
    end

    def get_png_pixel(id, x, y)
      p = @pngs[id]
      raise "Can't find png with id #{id}" unless p

      color = p[x,y]
      red = ChunkyPNG::Color.r(color)
      green = ChunkyPNG::Color.g(color)
      blue = ChunkyPNG::Color.b(color)
      alpha = ChunkyPNG::Color.a(color)

      {
        :red => red,
        :green => green,
        :blue => blue,
        :alpha => alpha
      }
    end

    def sketch_command(opts)
      cmd = {:type => :sketch, :opts => opts}
      sync_msg_command cmd
    end

    def circle(x, y, radius)
      sketch_command({:x => x, :y => y, :radius => radius, :cmd => :circle})
    end

    def load_sample(path)
      @studio.load_sample(path)
    end

    def sample_info(path)
      load_sample(path)
    end

    def sample(path, *args)
      buf_info = load_sample(path)
      synth_name = (buf_info[:num_chans] == 1) ? "overtone.sc.sample/mono-player" : "overtone.sc.saddd/stereo-player"
      @studio.trigger_non_sp_synth(synth_name, "buf", buf_info[:id], *args)
    end

    def image(x, y, src)
      local = false

      if(src.class == Symbol)
        p = @pngs[src]
        raise "Can't find png with id #{id}" unless p
        p.save("#{media_path}/#{src.to_s}.png", :interlace => true)
        src = "media/#{src}.png"
        local = true
      end

      if(src.class == String)
        if(File.exists? src)
          safe_src = src.gsub(/[^a-zA-Z0-9.]/, "_|_")
          src_basename = File.basename src
          media_src = "#{media_path}/#{safe_src}"
          unless(File.exists? media_src)
            FileUtils.cp(src, media_src)
          end
          src = "media/#{safe_src}"
          local = true
        end
      end

      cmd = {:type => :sketch, :opts => {:x => x, :y => y, :cmd => :image, :src => src, :local? => local}}
      sync_msg_command cmd
    end

    def clear
      sync_msg_command({:cmd => :clear})
    end
  end
end
