require 'test_helper'

describe Snp::CLI do
  describe '.parse_options' do
    it 'delegates to #parse' do
      double = stub(parse: 'double')
      Snp::CLI.stubs(:new).returns(double)

      Snp::CLI.parse_options.must_equal 'double'
    end
  end

  describe '#parse' do
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

    def no_exit(&block)
      block.call
    rescue SystemExit
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

      cli.parse

      stream.error.must_match /Invalid option: some_name/
    end
  end
end
