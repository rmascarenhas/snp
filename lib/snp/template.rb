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
  #   t.absolute_path    # => '/Users/john/.snp_templates/jquery.erb'
  #   t.compile(binding) # => '<html><head>...'
  class Template
    # Public: creates a new template instance.
    #
    # template_file - the basename of the template file.
    def initialize(template_file)
      @file = template_file
    end

    # Public: resolves a template file by looking in the template path.
    #
    # Returns a string with the full path of the template file, or nil if it is not
    # found.
    def absolute_path
      right_path = possible_paths.find do |path|
        File.exists?(File.join(path, template_with_extension))
      end

      if right_path
        File.join(right_path, template_with_extension)
      end
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

    # Internal: checks if the given name ends with '.erb'.
    #
    # template - the template file name.
    def has_erb_extension?(template)
      template[-4, 4] == '.erb'
    end

    # Internal: returns the path to be used when searching for templates. Defined by
    # the SNP_PATH environment variable, defaulting to `~/.snp_templates`.
    def snp_path
      path_from_env || default_path
    end

    # Internal: The default path to be used when the SNP_PATH environment variable
    # is not set.
    def default_path
      ['~/.snp_templates']
    end

    # Internal: parses the SNP_PATH environment variable, if it is set. The format
    # of this variable follows the same convention of the shell's PATH variable: a series
    # of directories separated by a collon.
    def path_from_env
      ENV['SNP_PATH'] && ENV['SNP_PATH'].split(':')
    end

    # Internal: expands each directory in the template path.
    #
    # Returns an array of strings with the expanded directory names.
    def possible_paths
      snp_path.map { |p| File.expand_path(p) }
    end

    # Internal: appends `.erb` exntesion to the template file name, unless it is
    # already present.
    def template_with_extension
      append_extension(@file)
    end

    # Internal: returns a string with the content of the template file.
    def template_content
      File.read(absolute_path)
    end
  end
end
