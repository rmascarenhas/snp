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

  # Snp::InvalidOptions
  #
  # This exception is raised when there is an error parsing command line options
  # passed to `snp`.
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
    # Public: extract template name and other data that should be used to compile the
    # template.
    #
    # arguments - an array of arguments that should be parsed. Defaults to `ARGV`.
    #
    # This method returns an array in which the first element is the template name and the
    # second are the data that should be used to compile the template.
    def self.parse_options(arguments = ARGV.dup)
      new(arguments).parse
    end

    # Internal: creates a new `Snp::CLI` instance.
    #
    # params - array of arguments.
    # stream - the stream to be used when there is feedback to be given to the user. This
    #          object must respond to `out` and `err` for normal and error situations.
    def initialize(params, stream = StandardStream.new)
      @params  = params
      @options = {}
      @stream  = stream
    end

    # Internal: actually does the parsing job.
    def parse
      template_name = parse_static_options
      template_data = parse_dynamic_options

      [template_name, template_data]
    rescue InvalidOptions => exception
      @stream.err exception.message
      @stream.err option_parser.to_s

      exit 1
    end

    private

    # Internal: parses the command line options to check for static options
    # (version number and help).
    def parse_static_options
      option_parser.parse!(@params)
      @params.pop
    end

    # Internal: parses dynamic options, creating options according to the arguments
    # passed on the command line.
    #
    # Example
    #
    #   # command is '--project snp --language ruby template_name'
    #   parse_dynamic_options # => { 'project' => 'snp', 'language' => 'ruby' }
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

    # Internal: builds the static option parser. Recognizes `-V` for version and `-h`
    # for help.
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

    # Internal: builds the dynamic option parser, that creates options on the fly according
    # to the passed command line options.
    def dynamic_parser
      @_dynamic_parser ||= Slop.new(autocreate: true)
    end

    # Internal: prints a message and exits.
    #
    # message - the message to be printed before exiting.
    #
    # This method finishes the current process with a success exit status.
    def print_and_exit(message)
      @stream.out message
      exit
    end

    # Internal: the program name to be used when generating output to the user.
    def program_name
      File.basename($0, '.*')
    end
  end
end
