# fluent-plugin-nostat
fluent plugin for system resource monitoring whithout dstat

## Installation
install with gem command as:

```
$ gem install fluent-plugin-nostat
```

## configuration

```
<source>
  type nostat
  run_interval 1
  mode dstat # raw or dstat
  output_type graphite # hash or graphite
</source>
```
* tag : If there is no tag value, the tag will be "{tag_prefix}.{hostname}.nostat".
* run_interval : seconds
* **mode** : raw or dstat. **raw** : just get the values from /proc/{STATS}. **dstat** : modify the values as dstat.
* **output_type** : hash or graphite. **hash** : old version style. **graphite** : slice all output for grapite.
* tag_prefix : If there is no tag value, the tag will be "{tag_prefix}.{hostname}.nostat".

## output
### raw mode
the raw stats from /proc directory.
* cpu : time - http://www.linuxhowtos.org/System/procstat.htm
* memory : KB - https://www.centos.org/docs/5/html/5.1/Deployment_Guide/s2-proc-meminfo.html
* disk I/O : sector - https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats
* network I/O : bytes - http://www.onlamp.com/pub/a/linux/2000/11/16/LinuxAdmin.html

```
cpu={"usr"=>52773, "sys"=>28330, "idl"=>2217987, "wai"=>1995, "siq"=>4112, "hiq"=>0} disk={"sda"=>{"read"=>"9786551", "write"=>"29250018"}} net={"enp0s3"=>{"recv"=>8940623796, "send"=>383889456}, "enp0s8"=>{"recv"=>8940623796, "send"=>383889456}} mem={"total"=>1884188, "free"=>67968, "buff"=>0, "cach"=>1546820, "used"=>269400}
```

### dstat mode
* cpu : percentage
* memory : bytes
* disk I/O : bytes/sec
* network I/O : bytes/sec
```
cpu={"usr"=>0, "sys"=>0, "idl"=>100, "wai"=>0, "siq"=>0, "hiq"=>0} mem={"free"=>1693290496, "buff"=>0, "cach"=>60887040, "used"=>175230976} disk={"sda"=>{"read"=>0, "write"=>0}} net={"enp0s3"=>{"recv"=>344, "send"=>1668}, "enp0s8"=>{"recv"=>344, "send"=>1668}}
```

### graphite output style
graphite output type is for [fluent-plugin-graphite](https://github.com/studio3104/fluent-plugin-graphite). To use this output type, graphite plugin should be installed by following command. There is no dependancy for that plugin yet.
```
gem install fluent-plugin-graphite
```

* full configuration example
```
<source>
  type nostat
  tag_prefix graphite.
  run_interval 60
  mode dstat
  output_type graphite
</source>

<match graphite.**>
  type graphite
  host 192.168.56.91
  port 2003
  tag_for prefix
  remove_tag_prefix graphite
  name_key_pattern ^*$
</match>

```

* output
```
tag : record
hostname.nostat.cpu : usr => 10
hostname.nostat.cpu : sys => 0
hostname.nostat.cpu : idl => 90
hostname.nostat.cpu : wai => 0

...

hostname.nostat.mem : free => 1693290496
hostname.nostat.mem : buff => 0
hostname.nostat.mem : cach => 60887040
hostname.nostat.mem : used => 175230976

...

```

## it was tested on
. CentOS 7.x (kernel 3.10.x) with graphite
