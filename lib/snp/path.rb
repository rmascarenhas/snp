module Snp
  # Snp::Path
  #
  # This class is intended to wrap the logic of finding the paths in which template
  # and data files should be placed.
  #
  # Example
  #
  #   Snp::Path.new.which('jquery') # => '/etc/snp/jquery.erb'
  class Path
    # Public: returns the list of absolute paths to the directories in which
    # the templates should be looked.
    def absolute_paths
      dir_list.map { |d| File.expand_path(d) }
    end

    # Public: resolves a template file by looking in the template path.
    #
    # template  - the template name.
    # extension - the extension of the desired template.
    #
    # Returns a string with the full path of the template file, or nil if it is not
    # found.
    def which(template, extension)
      template_with_extension = with_extension(template, extension)

      path = absolute_paths.find do |path|
        File.exists?(File.join(path, template_with_extension))
      end

      if path
        File.join(path, template_with_extension)
      end
    end

    private

    # Internal: retrieves a list of paths that should be searched by looking the `SNP_PATH`
    # environment variable or falling back to the default path.
    def dir_list
      path_from_env || default_path
    end

    # Internal: parses the SNP_PATH environment variable, if it is set. The format
    # of this variable follows the same convention of the shell's PATH variable: a series
    # of directories separated by a collon.
    def path_from_env
      ENV['SNP_PATH'] && ENV['SNP_PATH'].split(':')
    end

    # Internal: The default path to be used when the SNP_PATH environment variable
    # is not set.
    def default_path
      ['~/.snp']
    end

    # Internal: checks if the given name ends with the passed `extension`.
    #
    # template - the template file name.
    def has_extension?(template, extension)
      template[-4, 4] == ".#{extension}"
    end

    # Internal: appends a given extension to the template file name, unless it is
    # already present.
    #
    # template  - the template name.
    # extension - the extension to be appended.
    #
    # Examples
    #
    #   with_extension('template', 'erb')     # => 'template.erb'
    #   with_extension('template.erb', 'erb') # => 'template.erb'
    def with_extension(template, extension)
      if has_extension?(template, extension)
        template
      else
        [template, extension].join(".")
      end
    end
  end
end
