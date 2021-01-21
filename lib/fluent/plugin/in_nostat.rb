require 'fluent/plugin/input'
#
# by nozino (nozino@gmail.com)
#

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

    @@LINUX_SECTOR_SIZE_BYTE = 512

    @@history = {}

    def initialize
      super
      require 'fluent/timezone'
    end

    config_param :tag_prefix, :string, :default => nil
    config_param :tag, :string, :default => nil
    config_param :run_interval, :time, :default => nil
    config_param :mode, :string, :default => "raw"
    config_param :output_type, :string, :default => "hash"

    def configure(conf)
      super

      if !@tag
        @tag = @tag_prefix + `hostname`.strip.split('.')[0].strip + ".nostat"
      end
      if !@run_interval
        raise ConfigError, "'run_interval' option is required on nostat input"
      end
    end

    def start
      if ( @mode == "dstat" )
        @@history = get_stats
        sleep @run_interval
      end

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

      res["usr"] = first[@@CPU_USR].strip.to_f
      res["sys"] = first[@@CPU_SYS].strip.to_f
      res["idl"] = first[@@CPU_IDL].strip.to_f
      res["wai"] = first[@@CPU_WAI].strip.to_f
      res["siq"] = first[@@CPU_SIQ].strip.to_f
      res["hiq"] = first[@@CPU_HIQ].strip.to_f

      res
    end

    def get_mem_stat
      res = {}
      used = 0
      total = 0

      File.foreach(@@MEM_STAT) do |line|
        items = line.split
        name = items[0].split(':').first


        case name
          when "MemTotal"
#          res["total"] = items[1].strip.to_i
          total = items[1].strip.to_i
          when "MemFree"
          res["free"] = items[1].strip.to_i
          when "Buffers"
          res["buff"] = items[1].strip.to_i
          when "Cached"
          res["cach"] = items[1].strip.to_i
          else
        end
      end

      res["used"] = total - res["free"] - res["buff"] - res["cach"]
      res
    end

    def get_disk_stat
      res = {}

      File.foreach(@@DISK_STAT) do |line|
        items = line.split
        if ( items[2] =~ /^[hsv]d[a-z]$/ )
          disk = {}

          disk["read"] = items[5].strip.to_i
          disk["write"] = items[9].strip.to_i

          res[items[2]] = disk
        end
      end

      res
    end

    def get_net_stat
      res = {}

      File.foreach(@@NET_STAT).with_index do |line, index|
        if ( index < 2 )
          next
        end

        items = line.split
        name = items[0].split(':').first

        if ( name =~ /^lo$/ )
          next
        end

        net = {}

        net["recv"] = items[1].strip.to_i
        net["send"] = items[9].strip.to_i

        res[name] = net

      end

      res
    end

    def get_dstat_cpu (cpu_stat)
      res = {}
      total = 0
      cpu_stat.each do |key, value|
        res[key] = value - @@history["cpu"][key]
        total += res[key]
      end
        
      res.each do |key,value|
        if ( key == "idl" )
          res[key] = (res[key] / total * 100).floor
        else
          res[key] = (res[key] / total * 100).ceil
        end
      end
      
      res
    end

    def get_dstat_mem (mem_stat)
      res = {}
      mem_stat.each do |key, value|
        res[key] = value * 1024
      end

      res
    end

    def get_dstat_disk (disk_stat)
      res = {}

      disk_stat.each do |key, value|
        disk = {}
        disk["read"] = (((value["read"] - @@history["disk"][key]["read"]) * @@LINUX_SECTOR_SIZE_BYTE) / @run_interval).ceil
        disk["write"] = (((value["write"] - @@history["disk"][key]["write"]) * @@LINUX_SECTOR_SIZE_BYTE) / @run_interval).ceil
        res[key] = disk
      end

      res
    end

    def get_dstat_net (net_stat)
      res = {}

      net_stat.each do |key, value|
        net = {}
        net["recv"] = (((value["recv"] - @@history["net"][key]["recv"])) / @run_interval).ceil
        net["send"] = (((value["send"] - @@history["net"][key]["send"])) / @run_interval).ceil
        res[key] = net
      end

      res
    end

    def get_dstat_record (stat)
      record = {}
      record["cpu"] = get_dstat_cpu (stat["cpu"])
      record["mem"] = get_dstat_mem (stat["mem"])
      record["disk"] = get_dstat_disk (stat["disk"])
      record["net"] = get_dstat_net (stat["net"])

      @@history = stat

      record
    end

    def get_stats
      stat = {}

      stat["cpu"] = get_cpu_stat
      stat["disk"] = get_disk_stat
      stat["net"] = get_net_stat
      stat["mem"] = get_mem_stat
      
      stat
    end

    def emit_graphite_style (time, record)
      # cpu
      tag = @tag + ".cpu"
      router.emit(tag, time, record["cpu"])
      
      # memory
      tag = @tag + ".mem"
      router.emit(tag, time, record["mem"])

      # disk
      tag_prefix = @tag + ".disk"

      record["disk"].each do |key, value|
        tag = tag_prefix + "." + key
        router.emit(tag, time, value)
      end
      
      # net
      tag_prefix = @tag + ".net"

      record["net"].each do |key, value|
        tag = tag_prefix + "." + key
        router.emit(tag, time, value)
      end
    end

    def emit_record (time, record)
      if @output_type == "graphite"
        emit_graphite_style(time, record)
      elsif @output_type == "hash"
        router.emit(@tag, time, record)       
      else
        log.error "invalid output_type. output_type=", @output_type
      end
    end

    def run_periodic
      until @finished
        begin
          sleep @run_interval

          stat = get_stats

          if (mode == "dstat")
            record = get_dstat_record (stat)
          else
            record = stat
          end

          time = Engine.now
          
          emit_record(time,record)
        rescue => e
          log.error "nostat failed to emit", :error => e.to_s, :error_class => e.class.to_s, :tag => tag
          log.error "nostat to run or shutdown child process", :error => $!.to_s, :error_class => $!.class.to_s
          log.warn_backtrace $!.backtrace

        end
      end
    end
  end
end
