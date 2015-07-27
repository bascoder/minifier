require 'minitest/autorun'
require 'minitest/reporters'

MiniTest::Reporters.use! # MiniTest::Reporters::RubyMineReporter.new

class MyTest < MiniTest::Unit::TestCase
  # test setup files
  TEST_SETUP_DIR = 'test_files'
  MINIFY_SCRIPT = 'ruby minify.rb'

  def setup
    @dir = 'test_working_dir'
    @command = "#{MINIFY_SCRIPT} #{@dir}"

    # copy test files to working directory
    FileUtils.cp_r Dir.glob(TEST_SETUP_DIR + '/*'), @dir
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # remove files from working dir
    FileUtils.rm_rf Dir.glob("#{@dir}/*")
  end

  # test minify script
  def test_minify
    system @command

    # command should exit successfully
    assert $?.success?

    assert_minified
  end

  def assert_minified
    files = Dir.entries(@dir)
    assert files.include? 'another.min.js'
    assert files.include? 'another.min.map'
    assert files.include? 'test.js'
    assert files.include? 'test.min.js'

    minified_txt = files.include? ('fake.min.txt')
    assert_equal false, minified_txt
  end

  # when passing invalid arguments to script should exit
  def test_invalid_arguments
    system MINIFY_SCRIPT

    assert !$?.success?
  end

  def test_concurrent
    system @command + ' t'

    assert($?.success?, 'command should complete')
    assert_minified
  end
end
