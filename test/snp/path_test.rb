require 'test_helper'

describe Snp::Path do
  describe '#absolute_paths' do
    it 'defaults to the user home directory' do
      Snp::Path.new.absolute_paths.must_equal Array(File.expand_path('~/.snp_templates'))
    end

    it 'uses the value in the `SNP_PATH` variable when available' do
      ENV['SNP_PATH'] = '~/.snp:/etc/snp'

      Snp::Path.new.absolute_paths.must_equal [File.expand_path('~/.snp'), '/etc/snp']

      ENV['SNP_PATH'] = nil
    end
  end

  describe '#which' do
    def subject
      Snp::Path.new
    end

    it 'is nil in case there is no file in the path' do
      File.stubs(:exists?).returns(false)

      subject.which('template', 'erb').must_be_nil
    end

    it 'returns the absolute path to the template appending the extension' do
      File.stubs(:exists?).returns(true)

      subject.which('snp', 'erb').must_equal File.expand_path('~/.snp_templates/snp.erb')
    end

    it 'does not append extension if it template already has it' do
      File.stubs(:exists?).returns(true)

      subject.which('snp.erb', 'erb').must_equal File.expand_path('~/.snp_templates/snp.erb')
    end
  end
end
