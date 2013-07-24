require 'test_helper'

describe Snp::Data do
  describe '.for' do
    it 'delegates to #to_hash' do
      data = stub(to_hash: 'snp')
      Snp::Data.stubs(:new).returns(data)

      Snp::Data.for('anything').must_equal 'snp'
    end
  end

  describe '#to_hash' do
    it 'is empty when no data file is found' do
      File.stubs(:exists?).returns(false)

      Snp::Data.new('snp').to_hash.must_equal({})
    end

    it 'parses the content of the data file' do
      data = { name: 'snp', language: 'ruby' }
      path = File.expand_path('~/.snp/snp.yml')

      File.stubs(:exists?).returns(true)
      YAML.stubs(:load_file).with(path).returns(data)

      Snp::Data.new('snp').to_hash.must_equal data
    end
  end
end
