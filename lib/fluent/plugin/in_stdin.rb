#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

module Fluent
  class StdinInput < Input
    Plugin.register_input('stdin', self)

    config_param :format, :string
    config_param :delimiter, :string, :default => "\n"
    config_param :tag, :string, :default => 'stdin.events'

    def configure(conf)
      super

      @parser = Plugin.new_parser(@format)
      @parser.configure(conf)
    end

    def start
      @buffer = "".force_encoding('ASCII-8BIT')
      @thread = Thread.new(&method(:run))
    end

    def shutdown
      @thread.join
    end

    def run
      while true
        begin
          @buffer << $stdin.sysread(4000)
          pos = 0

          while i = @buffer.index(@delimiter, pos)
            msg = @buffer[pos...i]
            emit_event(msg)
            pos = i + @delimiter.length
          end
          @buffer.slice!(0, pos) if pos > 0
        rescue IOError, EOFError => e
          # ignore above exceptions because can't re-open stdin automatically
          break
        rescue => e
          log.error "unexpected error", :error=> e.to_s
          log.error_backtrace
          break
        end
      end
    end

    def emit_event(msg)
      @parser.parse(msg) { |time, record|
        unless time && record
          log.warn "pattern not match: #{msg.inspect}"
          return
        end

        router.emit(@tag, time, record)
      }
    rescue => e
      log.error msg.dump, :error => e, :error_class => e.class
      log.error_backtrace
    end
  end
end
