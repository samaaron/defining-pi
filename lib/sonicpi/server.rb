require 'osc-ruby'
require_relative "util"
require_relative "group"
require_relative "synthnode"
require_relative "audiobusallocator"
require_relative "controlbusallocator"
require_relative "incomingchan"

module SonicPi
  class Server
    include Util

    attr_accessor :current_node_id,  :debug, :mouse_y, :mouse_x

    ID_SEM = Mutex.new
    OSC_SEM = Mutex.new
    PRINT_SEM = Mutex.new
    BUS_SEM = Mutex.new
    CALLBACK_SEM = Mutex.new
    INCOMING_MSG_SEM = Mutex.new
    ROOT_GROUP = 0

    def initialize(hostname, port, msg_queue)
      @hostname = hostname
      @msg_queue = msg_queue
      message "Initialising comms... #{msg_queue}"
      @port = port
      @chan = IncomingChan.new
      puts "ooooh #{@chan}"
      @client = OSC::Server.new(4800)

      @client.add_method '*' do |m|
        @chan.push m
      end

      clear_scsynth!
      request_notifications

      @current_node_id = 1
      @busses = []
      @audio_bus_allocator = AudioBusAllocator.new 100, 10 #TODO: remove these magic nums
      @control_bus_allocator = ControlBusAllocator.new 1000, 0
      @callbacks = {}
      @server_thread = Thread.new do
        puts "stating server thread"
        @client.run
      end
    end

    def message(s)
       @msg_queue.push "Comms: #{s}"
    end

    def request_notifications
      message "Requesting notifications"
      osc "/notify", 1
    end

    def load_synthdefs(path)
      message "Loading synthdefs from path: #{path}"
      osc "/d_loadDir", path.to_s
      sleep 2 ## TODO: replace me with a blocking wait (for a callback)
    end

    def clear_scsynth!
      message "Clearing scsynth"
      ID_SEM.synchronize do
        @current_node_id = 1
        clear_schedule
        group_clear 0
      end
    end

    def clear_schedule
      osc "/clearSched"
    end

    def reset!
      clear_schedule
      clear_scsynth!
      @audio_bus_allocator.reset!
      @control_bus_allocator.reset!

    end

    def position_code(position)
      {head: 0,
        tail: 1,
        before: 2,
        after: 3,
        replace: 4}[position]
    end

    def group_clear(id)
      message "Clearing (nuking) group #{id}"
      osc "/g_freeAll", id.to_f
    end

    def group_deep_free(id)
      message "Deep freeing group #{id}"
      osc "/g_deepFree", id.to_f
    end

    def kill_node(id)
      message "Killing node #{id}"
      osc "/n_free", id.to_f
    end

    def create_group(position, target)
      target_id = target.to_i
      pos_code = position_code(position)
      id = new_node_id
      if (pos_code && target_id)
        message "Group created with id: #{id}"
        osc "/g_new", id.to_f, pos_code.to_f, target_id.to_f
        Group.new id, self
      else
        message "Unable to create a node with position: #{position} and target #{target}"
        nil
      end
    end

    def allocate_audio_bus(num_chans)
      @audio_bus_allocator.allocate num_chans
    end

    def allocate_control_bus(num_chans)
      @control_bus_allocator.allocate num_chans
    end

    def new_node_id
      ID_SEM.synchronize do
        @current_node_id += 1
      end
    end

    def trigger_synth(position, group, synth_name, *args)
      message "Triggering synth #{synth_name} at #{position}, #{group.to_s}"
      pos_code = position_code(position)
      group_id = group.to_i
      node_id = new_node_id
      normalised_args = []
      args.each_slice(2){|el| normalised_args.concat([el.first.to_s, el[1].to_f])}
      osc "/s_new", synth_name.to_s, node_id.to_f, pos_code.to_f, group_id.to_f, *normalised_args
      SynthNode.new(node_id.to_f, self, synth_name.to_s)
    end

    def node_ctl(node, *args)
      message "controlling node: #{node} with args: #{args}"
      normalised_args = []
      args.each_slice(2){|el| normalised_args.concat([el.first.to_s, el[1].to_f])}
      osc "/n_set", node.to_f, *normalised_args
    end

    def status
      osc "/status"
      info = @chan.pop_status
      args = info.args
      {
        :ugens => args[1],
        :synths => args[2],
        :groups => args[3],
        :sdefs => args[4],
        :avg_cpu => args[5],
        :peak_cpu => args[6],
        :nom_samp_rate => args[7],
        :act_samp_rate => args[8]
      }
    end

    def osc(*args)
      OSC_SEM.synchronize do
        message "--> osc: #{args}"
        @client.send(OSC::Message.new(*args), @hostname, @port)
      end
    end

  end
end
