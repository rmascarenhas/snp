require 'yaml'

module Snp
  # Snp::Compiler
  #
  # This class takes a template file name and builds it, using the template
  # definition, default data to be used and extra options that override the
  # default ones.
  #
  # Example
  #
  #   Compiler.build('js.html', inline: true)
  class Compiler
    def self.build(template_name, extra_options)
      new(template_name, extra_options).compile
    end

    # Public: creates a new Snp::Compiler instance.
    #
    # template      - the template name.
    # extra_options - options to override default data to build the template.
    def initialize(template, extra_options)
      @template = template
      @options  = extra_options
    end

    # Public: actually compiles the template.
    #
    # Returns a string with the compiled version of the snippet.
    def compile
      template.compile(compilation_context)
    end

    private

    # Internal: builds the ERB context to be used to generate the snippet.
    # Consists of the default for the template plus the extra options
    # passed on initialization.
    def compilation_context
      TemplateContext.for(default_data.merge(@options))
    end

    # Internal: searches the default data file for the template and parses it.
    #
    # Returns a hash with the default data if available, or an empty hash otherwise.
    def default_data
      Data.for(@template)
    end

    def template
      Template.new(@template, path)
    end

    def path
      @_path ||= Path.new
    end
  end
end
