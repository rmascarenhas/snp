require 'tempfile'
require 'slop'

module Snp
  # Snp::Printer
  #
  # This class is responsible for outputing string in normal output and error streams.
  # It defaults to `STDOUT` and `STDERR`, respectively but can be used to generate output
  # for other streams.
  #
  # Example
  #
  #   stream = Snp::Printer.new
  #   stream.out('Hello')  # => 'Hello' is written to the standard output
  #   stream.err('ERROR!') # => 'ERROR!' is written to the standard error
  class Printer
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
    # This method generates the snippet and fires your text editor in case it is set up,
    # or prints the snippet to the standard output.
    def self.run(arguments = ARGV.dup)
      new(arguments).start
    end

    attr_reader :printer

    # Internal: creates a new `Snp::CLI` instance.
    #
    # params  - array of arguments.
    # printer - the printer object through which feedback messages are sent to.
    #           The passed object must respond to `out` and `err` for normal
    #           and error situations, respectively.
    def initialize(params, printer = Printer.new)
      @params  = params
      @options = {}
      @printer = printer
    end

    # Internal: actually does the parsing job and compiles the snippet.
    def start
      template_name, template_data = parse
      set_template_extension(template_name)

      snippet = Compiler.build(template_name, template_data)

      edit(snippet) || printer.out(snippet)
    rescue => exception
      printer.err exception.message
      help_and_exit
    end

    # Internal: parses command line options.
    #
    # Returns the template name and extra options to be used when compiling
    # the snippet, extracted from command line arguments.
    def parse
      help_and_exit if no_options_passed?

      template_name = parse_static_options
      template_data = parse_dynamic_options

      [template_name, template_data]
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
      if no_options_passed?
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
      printer.out message
      exit
    end

    # Internal: returns the editor that should be used when editing a generated
    # snippet. Looks for editor names in the `SNP_EDITOR` and `EDITOR` environment
    # variables, respectively.
    def editor
      @_editor ||= ENV['SNP_EDITOR'] || ENV['EDITOR']
    end

    # Internal: Opens the preferred text editor with the content of a snippet.
    #
    # snippet - a string with the snippet content that should be edited.
    def edit(snippet)
      if editor && !editor.empty?
        with_tempfile_for(snippet) do |file|
          Process.exec "#{editor} '#{file.path}'"
        end
      end
    end

    # Internal: creates a `Tempfile` object the given content and yields it for use.
    #
    # content - the content of the tempfile.
    def with_tempfile_for(content)
      if @extension
        identifiers = ['snp', @extension]
      else
        identifiers = 'snp'
      end

      file = Tempfile.new(identifiers)
      file.write(content)
      file.rewind

      yield file
    ensure
      file.close
      file.unlink
    end

    # Internal: the program name to be used when generating output to the user.
    def program_name
      File.basename($0, '.*')
    end

    # Internal: prints help message and exits with a failure exit status.
    def help_and_exit
      printer.err help_message
      exit 1
    end

    # Internal: returns the help message for the `snp` command.
    def help_message
      option_parser.to_s
    end

    # Internal: checks whether or not any arguments were passed on the command line.
    def no_options_passed?
      @params.empty?
    end

    # Internal: returns the extension for a template name, to be used in the 
    # generated snippet.
    #
    # name - the template name.
    #
    # Example
    #
    #   set_template_extesion('snp.html') # => @extension is '.html'
    def set_template_extension(name)
      match_data = name.match(/.+(\..+)/)

      if match_data
        @extension = match_data[1]
      end
    end
  end
end
