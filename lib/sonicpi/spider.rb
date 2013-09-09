require_relative "util"
require_relative "studio"

require 'thread'

module SonicPi
  class Spider
    attr_reader :event_queue

    def initialize(hostname, port, msg_queue, max_concurrent_synths)
      @studio = Studio.new(hostname, port, msg_queue, max_concurrent_synths)
      @msg_queue = msg_queue
      @event_queue = Queue.new
      @keypress_handlers = {}

      message "Starting..."

      @keypress_handlers[:foo] = lambda {|e| play(60) }

      Thread.new do
        loop do
          event = @event_queue.pop
          handle_event event
        end
      end
    end

    def handle_event(e)
      case e[:type]
      when :keypress
        @keypress_handlers.values.each{|h| h.call(e)}
        else
          puts "Unknown event: #{e}"
        end
    end

    def message(s)
      @msg_queue.push({:type => :message, :val => s})
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

    def sketch_command(opts)
      cmd = {:type => :sketch, :opts => opts}
      @msg_queue.push(cmd)
    end

    def circle(x, y, radius)
      sketch_command({:x => x, :y => y, :radius => radius})
    end

  end
end
