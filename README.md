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
</source>
```
* **mode** : raw or dstat
** **raw** : just get the value from /proc/{STATS}
** **dstat** : modify values as dstat

## output
the raw stats from /proc directory.
* cpu : time - http://www.linuxhowtos.org/System/procstat.htm
* memory : KB - https://www.centos.org/docs/5/html/5.1/Deployment_Guide/s2-proc-meminfo.html
* disk : sector - https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats
* network : bytes - http://www.onlamp.com/pub/a/linux/2000/11/16/LinuxAdmin.html

### raw mode
```
cpu={"usr"=>52773, "sys"=>28330, "idl"=>2217987, "wai"=>1995, "siq"=>4112, "hiq"=>0} disk={"sda"=>{"read"=>"9786551", "write"=>"29250018"}} net={"enp0s3"=>{"recv"=>8940623796, "send"=>383889456}, "enp0s8"=>{"recv"=>8940623796, "send"=>383889456}} mem={"total"=>1884188, "free"=>67968, "buff"=>0, "cach"=>1546820, "used"=>269400}
```

### dstat mode
```
cpu={"usr"=>0, "sys"=>0, "idl"=>100, "wai"=>0, "siq"=>0, "hiq"=>0} mem={"free"=>1693290496, "buff"=>0, "cach"=>60887040, "used"=>175230976} disk={"sda"=>{"read"=>0, "write"=>0}} net={"enp0s3"=>{"recv"=>344, "send"=>1668}, "enp0s8"=>{"recv"=>344, "send"=>1668}}
```

## it was tested on
. CentOS 7.x (kernel 3.10.x)
