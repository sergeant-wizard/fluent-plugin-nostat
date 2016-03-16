module Fluent
  class NostatInput < Input
    Plugin.register_input('nostat', self)

    @@CPU_STAT = "/proc/stat"
    @@MEM_STAT = "/proc/meminfo"
    @@DISK_STAT = "/proc/diskstats"
    @@NET_STAT = "/proc/net/dev"

    @@CPU_USR = 1
    @@CPU_SYS = 3
    @@CPU_IDL = 4
    @@CPU_WAI = 5
    @@CPU_HIQ = 6
    @@CPU_SIQ = 7
    
    def initialize
      super
      require 'fluent/timezone'
    end
n
    config_param :tag_prefix, :string, :default => nil
    config_param :tag, :string, :default => nil
    config_param :run_interval, :time, :default => nil

    def configure(conf)
      super

      if !@tag
        @tag = @tag_prefix + `hostname`.strip.split('.')[0].strip + ".nostat"
        log.info "tag=", @tag
      end
      if !@run_interval
        raise ConfigError, "'run_interval' option is required on df input"
      end
    end

    def start
      @finished = false
      @thread = Thread.new(&method(:run_periodic))
    end

    def shutdown
      @finished = true
      @thread.join
    end

    def get_cpu_stat
      res = {}

      first = File.foreach(@@CPU_STAT).first.split

      res["usr"] = first[@@CPU_USR].strip.to_i
      res["sys"] = first[@@CPU_SYS].strip.to_i
      res["idl"] = first[@@CPU_IDL].strip.to_i
      res["wai"] = first[@@CPU_WAI].strip.to_i
      res["siq"] = first[@@CPU_SIQ].strip.to_i
      res["hiq"] = first[@@CPU_HIQ].strip.to_i

      res
    end

    def get_mem_stat
      res = {}
      used = 0

      File.foreach(@@MEM_STAT) do |line|
        items = line.split
        name = items[0].split(':').first

        case name
          when "MemTotal"
          res["total"] = items[1].strip.to_i
          when "MemFree"
          res["free"] = items[1].strip.to_i
          when "Buffers"
          res["buff"] = items[1].strip.to_i
          when "Cached"
          res["cach"] = items[1].strip.to_i
          else
        end
      end

      res["used"] = res["total"] - res["free"] - res["buff"] - res["cach"]
      res
    end

    def get_disk_stat
      res = {}

      File.foreach(@@DISK_STAT) do |line|
        items = line.split
        if ( items[2] =~ /^[hsv]d[a-z]$/ )
          disk = {}

          disk["read"] = items[5]
          disk["write"] = items[9]

          res[items[2]] = disk
        end
      end

      res
    end

    def get_net_stat
      res = {}
      net = {}

      File.foreach(@@NET_STAT).with_index do |line, index|
        if ( index < 2 )
          next
        end

        items = line.split
        name = items[0].split(':').first

        if ( name =~ /^lo$/ )
          next
        end

        net["recv"] = items[1].strip.to_i
        net["send"] = items[9].strip.to_i

        res[name] = net
      end

      res
    end

    def run_periodic
      until @finished
        begin
          sleep @run_interval

          record = {}

          record["cpu"] = get_cpu_stat
          record["disk"] = get_disk_stat
          record["net"] = get_net_stat
          record["mem"] = get_mem_stat

          emit_tag = @tag.dup
          time = Engine.now

          router.emit(@tag, time, record)
        rescue => e
          log.error "nostat failed to emit", :error => e.to_s, :error_class => e.class.to_s, :tag => tag
          log.error "nostat to run or shutdown child process", :error => $!.to_s, :error_class => $!.class.to_s
          log.warn_backtrace $!.backtrace

        end
      end
    end
  end
end
