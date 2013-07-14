require 'slop'

module Snp
  # Snp::StandardStream
  #
  # This class is responsible for outputing string in normal output and error streams.
  # It defaults to `STDOUT` and `STDERR`, respectively but can be used to generate output
  # for other streams.
  #
  # Example
  #
  #   stream = Snp::StandardStream.new
  #   stream.out('Hello')  # => 'Hello' is written to the standard output
  #   stream.err('ERROR!') # => 'ERROR!' is written to the standard error
  class StandardStream
    def initialize(out = STDOUT, err = STDERR)
      @out = out
      @err = err
    end

    def out(message)
      @out.puts message
    end

    def err(message)
      @err.puts message
    end
  end

  class InvalidOptions < StandardError
    def initialize(invalid_option)
      super("Invalid option: #{invalid_option}")
    end
  end

  # Snp::CLI
  #
  # This class is responsible for parsing command line options passed to `snp` and
  # retrieve the template name to be compiled and possibly options to override data
  # for the template.
  #
  # Example
  #
  #   CLI.parse_options # => ['/Users/john/.snp/jquery.html.erb', { version: '1.9' }]
  class CLI
    def self.parse_options(arguments = ARGV.dup)
      new(arguments).parse
    end

    def initialize(params, stream = StandardStream.new)
      @params  = params
      @options = {}
      @stream  = stream
    end

    def parse
      template_name = parse_static_options
      template_data = parse_dynamic_options

      [template_name, template_data]
    rescue InvalidOptions => exception
      @stream.err exception.message
      @stream.err option_parser.to_s
    end

    private

    def parse_static_options
      option_parser.parse!(@params)
      @params.pop
    end

    def parse_dynamic_options
      if @params.empty?
        {}
      else
        dynamic_parser.parse!(@params)

        data = dynamic_parser.to_hash
        invalid_key = data.find { |key, value| value.nil? }

        if invalid_key
          raise InvalidOptions.new(invalid_key.first)
        end

        data
      end
    end

    def option_parser
      @_option_parser ||= Slop.new do |command|
        command.banner "Usage: #{program_name} [options] [template_name]"

        command.on('-V', 'Shows version and exits') do
          print_and_exit Snp::VERSION
        end

        command.on('-h', 'Shows this message') do
          print_and_exit command.to_s
        end
      end
    end

    def dynamic_parser
      @_dynamic_parser ||= Slop.new(autocreate: true)
    end

    def print_and_exit(message)
      @stream.out message
      exit
    end

    def program_name
      File.basename($0, '.*')
    end
  end
end
