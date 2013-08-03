require 'test_helper'
require 'snp/cli'

describe Snp::CLI do
  class TestStream
    attr_reader :output, :error

    def initialize
      @output = ''
      @error  = ''
    end

    def out(message)
      @output << message
    end

    def err(message)
      @error << message
    end
  end

  describe '.parse_options' do
    it 'delegates to #run' do
      double = stub(start: 'double')
      Snp::CLI.stubs(:new).returns(double)

      Snp::CLI.run.must_equal 'double'
    end
  end

  describe '#parse' do
    def no_exit(&block)
      block.call
    rescue SystemExit
    end

    it 'prints help message when no arguments are passed' do
      stream = TestStream.new
      cli    = Snp::CLI.new([], stream)

      no_exit { cli.parse }

      stream.output.wont_be_nil
    end

    it 'can print version' do
      stream = TestStream.new
      cli    = Snp::CLI.new(['-V'], stream)

      no_exit { cli.parse }

      stream.output.must_equal Snp::VERSION
    end

    it 'can print help message' do
      stream = TestStream.new
      cli    = Snp::CLI.new(['-h'], stream)

      no_exit { cli.parse }

      stream.output.wont_be_nil
    end

    it 'retrieves the template name' do
      cli = Snp::CLI.new(['snp'])
      options = cli.parse

      options.must_equal ['snp', {}]
    end

    it 'fetches dynamic options' do
      cli = Snp::CLI.new(['--type', 'gem', '--count', '3', 'snp'])
      options = cli.parse

      options.must_equal ['snp', { type: 'gem', count: '3' }]
    end

    it 'throws an error if more than one template name is given' do
      stream = TestStream.new
      cli = Snp::CLI.new(['--count', '3', 'some_name', 'snp'], stream)

      lambda {
        no_exit { cli.parse }
      }.must_raise(Snp::InvalidOptions)
    end
  end

  describe '#start' do
    it 'writes the compiled version to its output stream' do
      stream = TestStream.new
      cli = Snp::CLI.new(['snp'], stream)
      Snp::Compiler.stubs(:build).returns('compiled snippet')

      cli.start

      stream.output.must_equal 'compiled snippet'
    end
  end
end
