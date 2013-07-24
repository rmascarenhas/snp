require 'test_helper'

describe Snp::TemplateContext do
  describe '.for' do
    it 'delegates to #erb_binding' do
      context = stub(erb_binding: 'binding')
      Snp::TemplateContext.stubs(:new).returns(context)

      Snp::TemplateContext.for('template_name').must_equal 'binding'
    end
  end

  describe '#erb_binding' do
    it 'returns an instance of `Binding`' do
      Snp::TemplateContext.new(key: 'value').erb_binding.must_be_instance_of Binding
    end
  end

  it 'responds to methods passed as hash' do
    context = Snp::TemplateContext.new(greeting: 'Hello', name: 'snp')
    context.greeting.must_equal 'Hello'
    context.name.must_equal 'snp'
  end

  it 'generates predicate methods for boolean attributes' do
    context = Snp::TemplateContext.new(awesome: true, sad: false)
    context.awesome?.must_equal true
    context.sad?.must_equal false
  end

  it 'politely responds to methods named after context keys' do
    context = Snp::TemplateContext.new(snp: 'snp')
    context.must_respond_to(:snp)
  end

  it 'raises proper error when called with non-existing property' do
    context = Snp::TemplateContext.new(snp: 'snp')
    lambda {
      context.invalid_property
    }.must_raise(Snp::TemplateContext::InsufficientContext)
  end
end
