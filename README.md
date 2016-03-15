# fluent-plugin-nostat
fluent plugin for system resource monitoring whithout dstat

# Installation
install with gem or fluent-gem command as:

```
$ gem install fluent-plugin-nostat
```

# configuration

```
<source>
  type nostat
  run_interval 1
</source>
```

# it was tested on
. CentOS 7.x (kernel 3.10.x)
