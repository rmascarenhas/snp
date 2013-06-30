require 'test_helper'

describe Snp::Template do
  describe '#resolve' do
    it 'defaults to the user home directory' do
      template = Snp::Template.new
      File.stubs(:exists?).returns(true)

      template.resolve('template.erb').must_equal File.expand_path('~/.snp_templates/template.erb')
    end
  end
end
