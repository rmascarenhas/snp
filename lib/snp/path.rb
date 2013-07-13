module Snp
  # Snp::Path
  #
  # This class is intended to wrap the logic of finding the paths in which template
  # and data files should be placed.
  #
  # Example
  #
  #   Snp::Path.dirs # => ['/Users/john/.snp/templates', '/etc/snp']
  class Path
    # Public: returns the path to be used when searching for templates. Defined by
    # the SNP_PATH environment variable, defaulting to `~/.snp_templates`.
    def self.dirs
      new.absolute_paths
    end

    def absolute_paths
      dir_list.map { |d| File.expand_path(d) }
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
      ['~/.snp_templates']
    end
  end
end
