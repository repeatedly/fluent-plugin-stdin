require 'fluent/test'
require 'fluent/plugin/in_stdin'

class StdinInputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
    r, w = IO.pipe
    $stdin = r
    @writer = w
  end

  def teardown
    $stdin = STDIN
  end

  def create_driver(conf)
    Fluent::Test::InputTestDriver.new(Fluent::StdinInput).configure(conf)
  end

  def test_configure
    d = create_driver("format none")
    assert_equal 'stdin.events', d.instance.tag
    assert_equal "\n", d.instance.delimiter
  end

  {
    'none' => [
      {'msg' => "tcptest1\n", 'expected' => 'tcptest1'},
      {'msg' => "tcptest2\n", 'expected' => 'tcptest2'},
    ],
    'json' => [
      {'msg' => {'k' => 123, 'message' => 'tcptest1'}.to_json + "\n", 'expected' => 'tcptest1'},
      {'msg' => {'k' => 'tcptest2', 'message' => 456}.to_json + "\n", 'expected' => 456},
    ]
  }.each { |format, test_cases|
    define_method("test_msg_size_#{format}") do
      d = create_driver("format #{format}")
      tests = test_cases

      d.run do
        tests.each { |test|
          @writer.write test['msg']
        }
        @writer.close
        sleep 1
      end

      compare_test_result(d.emits, tests)
    end
  }

  def compare_test_result(emits, tests)
    assert_equal(2, emits.size)
    emits.each_index {|i|
      assert_equal(tests[i]['expected'], emits[i][2]['message'])
    }
  end
end
