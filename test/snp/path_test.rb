require 'test_helper'

describe Snp::Path do
  describe '.dir' do
    it 'delegates to `absolute_paths`' do
      double = stub(absolute_paths: ['/'])
      Snp::Path.stubs(:new).returns(double)

      Snp::Path.dirs.must_equal ['/']
    end
  end

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
end
