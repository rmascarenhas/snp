require 'test_helper'

describe Snp::Template do
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
