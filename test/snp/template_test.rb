require 'test_helper'

describe Snp::Template do
  describe '#resolve' do
    it 'defaults to the user home directory' do
      template = Snp::Template.new
      File.stubs(:exists?).returns(true)

      template.resolve('template.erb').must_equal File.expand_path('~/.snp_templates/template.erb')
    end

    it 'uses SNP_PATH environment variable if it is set' do
      ENV['SNP_PATH'] = '/snp:/etc/snp'
      File.stubs(:exists?).returns(true)

      template = Snp::Template.new
      template.resolve('template.erb').must_equal '/snp/template.erb'

      ENV['SNP_PATH'] = nil
    end

    it 'returns nil when there is no file with the given name' do
      template = Snp::Template.new
      File.stubs(:exists?).returns(false)

      template = Snp::Template.new
      template.resolve('inexistent.erb').must_be_nil
    end
  end
end
