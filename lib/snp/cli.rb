require 'slop'

module Snp
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
    def self.parse_options(arguments = ARGV)
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
    rescue InvalidOptions
      @stream.err option_parser
    end

    private

    def option_parser
      Slop.new(autocreate: true) do |command|
        command.banner "Usage: #{program_name} [options] [template_name]"

        command.on('-V', 'Shows version and exits') do
          print_and_exit Snp::VERSION
        end

        command.on('-h', 'Shows this message') do
          print_and_exit command
        end
      end
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
