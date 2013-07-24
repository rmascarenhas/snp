require 'yaml'

module Snp
  # Snp::Data
  #
  # This class is responsible for fetching the default data to be used when
  # compiling a template. This defaults to the data available on a YAML file
  # located in `SNP_PATH`, if available.
  #
  # Example
  #
  #   # Given there is a jquery.yml file in `SNP_PATH`, then
  #   data = Snp::Data.for('jquery')
  #   # => { 'version' => '1.9', 'cdn' => true }
  class Data
    # Public: fetches the default data for the given template and parses it.
    #
    # template - the template name whose data is to be fetched.
    #
    # Returns a hash with the data.
    def self.for(template)
      new(template).to_hash
    end

    # Public: creates a new `Snp::Data` instance for the template given.
    def initialize(template, path = Path.new)
      @template = template
      @path     = path
    end

    # Public: fetches the data file and parses it, if available.
    #
    # Returns a hash of the parsed data.
    def to_hash
      if absolute_path
        YAML.load_file(absolute_path)
      else
        {}
      end
    end

    private

    # Internal: returns the absolute path to the template file, searching for the
    # directories in `SNP_PATH`.
    def absolute_path
      @path.which(@template, 'yml')
    end
  end
end
