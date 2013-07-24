require 'test_helper'

describe Snp::Compiler do
  describe '.build' do
    it 'delegates to #compile' do
      compiler = stub(compile: 'compiled snippet')
      Snp::Compiler.stubs(:new).returns(compiler)

      Snp::Compiler.build('snp', {}).must_equal 'compiled snippet'
    end
  end

  describe '#compile' do
    def template_content
      '<% if say_hello? %>' +
        'Hello, <%= name %>' +
      '<% else %>' +
        'Farewell, <%= name %>' +
      '<% end %>'
    end

    def default_options
      { say_hello: true, name: 'John' }
    end

    def stub_file_operations
      File.stubs(:exists?).returns(true)
      File.stubs(:read).returns(template_content)
      YAML.stubs(:load_file).returns(default_options)
    end

    it 'generates compiled snippet when all options are available' do
      stub_file_operations
      Snp::Compiler.new('template_name', {}).compile.must_equal 'Hello, John'
    end

    it 'overrides default data with the ones passed' do
      stub_file_operations
      Snp::Compiler.new('template_name', name: 'Arthur').compile.must_equal 'Hello, Arthur'
    end
  end
end
