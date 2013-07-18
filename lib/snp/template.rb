require 'erb'

module Snp
  # Snp::Template
  #
  # The Template class represents a snippet definition through an ERB template.
  # Template files are looked in a series of directories that can be defined via
  # the SNP_PATH environment variable. By default, these snippet definitions are
  # searched in the `.snp_templates` directory in your home directory.
  #
  # Examples
  #
  #   t = Snp::Template.new('jquery.erb')
  #   t.compile(binding) # => '<html><head>...'
  class Template
    # Public: creates a new template instance.
    #
    # template_file - the basename of the template file.
    def initialize(template_file, path = Path.new)
      @file = template_file
      @path = path
    end

    # Public: compiles the template content to an effective snippet, ready to use.
    #
    # context - a `Binding` object to be used as context in the template compilation.
    #
    # Returns a string with the compiled template.
    def compile(context)
      ERB.new(template_content).result(context)
    end

    private

    # Internal: appends an ERB extension to the template file name passed, unless it already
    # contains one.
    #
    # template - the template file name.
    #
    # Examples:
    #
    # append_extension('template.erb') # => 'template.erb'
    # append_extension('template')     # => 'template.erb'
    def append_extension(template)
      if has_erb_extension?(template)
        template
      else
        template + '.erb'
      end
    end

    # Internal: returns a string with the content of the template file.
    def template_content
      File.read(absolute_path)
    end

    # Internal: returns the absolute path to the template, or `nil`, in case it is
    # not found.
    def absolute_path
      @path.which(@file, 'erb')
    end
  end
end
