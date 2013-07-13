require 'test_helper'

describe Snp::Template do
  def path
    ['/Users/john/.snp_templates']
  end

  describe '#absolute_path' do
    it 'defaults to the user home directory' do
      template = Snp::Template.new('template.erb', path)
      File.stubs(:exists?).returns(true)

      template.absolute_path.must_equal '/Users/john/.snp_templates/template.erb'
    end

    it 'returns nil when there is no file with the given name' do
      template = Snp::Template.new('inexistent.erb', path)
      File.stubs(:exists?).returns(false)

      template.absolute_path.must_be_nil
    end

    it 'appends .erb extension when not given' do
      template = Snp::Template.new('template', path)
      File.stubs(:exists?).returns(true)

      template.absolute_path.must_equal '/Users/john/.snp_templates/template.erb'
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

      template = Snp::Template.new('template.erb', path)
      template.compile(ERBContext.new.context).must_equal 'Hello from snp'
    end
  end
end
