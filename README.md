# Fluentd plugin for reading events from stdin

Reading events from stdin for testing.

## Installation

Use RubyGems:

    gem install fluent-plugin-stdin

## Configuration

    <source>
      type stdin

      # Input pattern. It depends on Parser plugin
      format none

      # Optional. default is stdin.events
      tag foo.filtered
    </source>

After that, you can send logs to fluentd via stdin like below.

    cat /path/to/logs | fluentd -c stdin.conf

This plugin works on only non-daemon mode.

## Copyright

<table>
  <tr>
    <td>Author</td><td>Masahiro Nakagawa <repeatedly@gmail.com></td>
  </tr>
  <tr>
    <td>Copyright</td><td>Copyright (c) 2015- Masahiro Nakagawa</td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
