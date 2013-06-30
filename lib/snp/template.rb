module Snp
  class Template
    def resolve(template_file)
      right_path = possible_paths.find do |path|
        File.exists?(File.join(path, template_file))
      end

      if right_path
        File.join(right_path, template_file)
      end
    end

    private

    def snp_path
      @_path = path_from_env || default_path
    end

    def default_path
      ['~/.snp_templates']
    end

    def path_from_env
      ENV['SNP_PATH'] && ENV['SNP_PATH'].split(':')
    end

    def possible_paths
      snp_path.map { |p| File.expand_path(p) }
    end
  end
end
