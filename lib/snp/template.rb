require 'erb'

module Snp
  # Snp::TemplateNotFound
  #
  # This exception is raised in case the template file passed is not found in any
  # directory in snp path.
  class TemplateNotFound < StandardError
    def initialize(template_name, path)
      super("Template #{template_name} was not found in #{path.inspect}")
    end
  end

  # Snp::Template
  #
  # The Template class represents a snippet definition through an ERB template.
  # Template files are looked in a series of directories that can be defined via
  # the SNP_PATH environment variable. By default, these snippet definitions are
  # searched in the `.snp` directory in your home directory.
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
      if template_content
        ERB.new(template_content).result(context)
      else
        raise TemplateNotFound.new(@file, @path.absolute_paths)
      end
    end

    private

    # Internal: returns a string with the content of the template file.
    def template_content
      if absolute_path
        File.read(absolute_path)
      end
    end

    # Internal: returns the absolute path to the template, or `nil`, in case it is
    # not found.
    def absolute_path
      @path.which(@file, 'erb')
    end
  end
end
