require 'test_helper'

describe Snp::Template do
  describe '#absolute_path' do
    it 'defaults to the user home directory' do
      template = Snp::Template.new('template.erb')
      File.stubs(:exists?).returns(true)

      template.absolute_path.must_equal File.expand_path('~/.snp_templates/template.erb')
    end

    it 'uses SNP_PATH environment variable if it is set' do
      ENV['SNP_PATH'] = '/snp:/etc/snp'
      File.stubs(:exists?).returns(true)

      template = Snp::Template.new('template.erb')
      template.absolute_path.must_equal '/snp/template.erb'

      ENV['SNP_PATH'] = nil
    end

    it 'returns nil when there is no file with the given name' do
      template = Snp::Template.new('inexistent.erb')
      File.stubs(:exists?).returns(false)

      template.absolute_path.must_be_nil
    end

    it 'appends .erb extension when not given' do
      template = Snp::Template.new('template')
      File.stubs(:exists?).returns(true)

      template.absolute_path.must_equal File.expand_path('~/.snp_templates/template.erb')
    end
  end

  describe '#compile' do
    class ERBContext
      def greeting
        'Hello'
      end

      def name
        'snp'
      end

      def context
        binding
      end
    end

    it 'generates a string with the processed template' do
      template_content = '<%= greeting %> from <%= name %>'
      File.stubs(:read).returns(template_content)

      template = Snp::Template.new('template.erb')
      template.compile(ERBContext.new.context).must_equal 'Hello from snp'
    end
  end
end
